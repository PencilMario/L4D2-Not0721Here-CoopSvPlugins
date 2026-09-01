#define PLUGIN_VERSION "1.1"

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <console>
#include <logger>

public Plugin myinfo =
{
	name = "[ANY] [Debugger] Valve Profiler",
	description = "Measures per-plugin performance and provides a log with various counters",
	author = "Alex Dragokas",
	version = PLUGIN_VERSION,
	url = "https://github.com/dragokas/"
};

/*
	Commands:
	
	 - sm_debug - Start / stop vprof debug tracing
	
	Logfile:
	
	 - addons/sourcemod/logs/profiler__<DATE>_<TIME>.log
	 
	For details of implementation see also:
	https://github.com/alliedmodders/sourcemod/issues/1162
*/

const float LOG_MAX_WAITTIME = 60.0;
const float LOG_CHECK_INTERVAL = 5.0;
const int VPROF_CAPTURE_MAX_BYTES = 8388608;
const int VPROF_CHUNKS_PER_FRAME = 8;
const int VPROF_MIRROR_BYTES_PER_FRAME = 8192;

char g_sProfilerOutput[VPROF_CAPTURE_MAX_BYTES];
char 	g_PathPrefix[PLATFORM_MAX_PATH],
		g_PathProfilerLogger[PLATFORM_MAX_PATH],
		g_PathOrig[PLATFORM_MAX_PATH],
		g_PathProfilerLog[PLATFORM_MAX_PATH],
		g_PathCosole[] = "console.log";
ConVar 	g_CVarLogFile;
Handle 	g_hTimer;
Logger g_hProfilerLogger;
File 	g_hProfilerLogFile;
File 	g_hProfilerSourceFile;
char 	g_sProfilerSourcePath[PLATFORM_MAX_PATH];
int 	g_iProfilerOutputLength;
int 	g_iProfilerOutputOffset;
int 	g_iProfilerChunkCount;
bool 	g_bProfilerResultWriting;
bool 	g_bProfilerDirectOutput;
bool 	g_bProfilerSourceHasBytes;
bool 	g_bProfilerSourceEndsWithNewline;
File 	g_hMirrorSourceFile;
File 	g_hMirrorTargetFile;
int 	g_iMirrorOffset;
bool 	g_bMirrorCopying;
bool 	g_bL4D2;
int 	g_ptrFile;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_bL4D2 = (GetEngineVersion() == Engine_Left4Dead2);
	return APLRes_Success;
}

public void OnPluginStart()
{
	CreateConVar("sm_prof_version", PLUGIN_VERSION, "Plugin Version", FCVAR_NOTIFY | FCVAR_DONTRECORD);
	g_CVarLogFile = FindConVar("con_logfile");
	g_hProfilerLogger = new Logger("sm_vprofiler", LoggerType_NewLogFile);
	BuildPath(Path_SM, g_PathProfilerLogger, sizeof(g_PathProfilerLogger), "logs/sm_vprofiler.log");
	
	RegAdminCmd("sm_debug", Cmd_Debug, ADMFLAG_ROOT, "Start / stop the valve profiler");
	
	BuildPath(Path_SM, g_PathPrefix, sizeof(g_PathPrefix), "logs/profiler_");
}

public void OnPluginEnd()
{
	delete g_hTimer;
	delete g_hProfilerSourceFile;
	delete g_hProfilerLogFile;
	delete g_hMirrorSourceFile;
	delete g_hMirrorTargetFile;
}

public void OnConfigsExecuted()
{
	g_CVarLogFile.GetString(g_PathOrig, sizeof(g_PathOrig));
}

public Action Cmd_Debug(int client, int args)
{
	static bool start;
	char sTime[32];
	
	if( !start && (g_bProfilerResultWriting || g_bMirrorCopying || g_hTimer != null) )
	{
		ReplyToCommand(client, "[WAIT] Previous profiler result is still being written.");
		return Plugin_Handled;
	}

	if( !start )
	{
		delete g_hTimer;
		
		FormatTime(sTime, sizeof(sTime), "%F_%H-%M-%S", GetTime());
		FormatEx(g_PathProfilerLog, sizeof(g_PathProfilerLog), "%s_%s.log", g_PathPrefix, sTime);
		
		if( g_bL4D2 )
		{
			g_ptrFile = FileSize(g_PathCosole);
		}
		else {
			SetCvarSilent(g_CVarLogFile, g_PathProfilerLog);
		}
		g_hProfilerLogger.info("VPROF_START client=%d logger=%s output=%s", client, g_PathProfilerLogger, g_PathProfilerLog);
		
		ReplyToCommand(client, "\x04[START]\x05 Profiler is started...");
		ServerCommand("vprof_on");
		ServerExecute();
		RequestFrame(OnFrameDelay);
	}
	else
	{
		ReplyToCommand(client, "\x04[STOP]\x05 Profiler result written to: %s", g_PathProfilerLogger);
		RequestFrame(OnFrameDump);
	}
	start = !start;
	return Plugin_Handled;
}

public void OnFrameDump()
{
	// sm prof stop clears SourceMod's active profiler, so dump while it is active.
	ServerCommandEx(g_sProfilerOutput, sizeof(g_sProfilerOutput), "sm prof dump vprof");
	ServerCommand("sm prof stop vprof");
	ServerCommand("vprof_off");
	ServerExecute();

	// Capture directly first. The file path remains a fallback for engines or
	// reports that do not fit in ServerCommandEx's output buffer.
	if( WriteProfilerOutputToLogger(g_sProfilerOutput) )
	{
		// The result is written incrementally by OnFrameWriteProfilerOutput.
		return;
	}
	else {
		// Profiler needs some time for the fallback file to be flushed.
		if( g_bL4D2 )
		{
			// L4D2 has bugged con_logfile: https://github.com/ValveSoftware/Source-1-Games/issues/3601
			g_hTimer = CreateTimer(LOG_CHECK_INTERVAL, Timer_MirrorLog, 1);
		}
		else {
			g_hTimer = CreateTimer(LOG_MAX_WAITTIME, Timer_RestoreCvar);
		}
	}
}

public void OnFrameDelay()
{
	ServerCommand("sm prof start vprof");
}

void SetCvarSilent(ConVar cvar, char[] value)
{
	int flags = cvar.Flags;
	cvar.Flags &= ~ FCVAR_NOTIFY;
	cvar.SetString(value);
	cvar.Flags = flags;
}

bool WriteProfilerChunk(char[] sChunk, int length)
{
	sChunk[length] = '\0';
	if( g_hProfilerLogFile == null || !g_hProfilerLogger.WriteRawString(g_hProfilerLogFile, sChunk) )
	{
		return false;
	}
	g_iProfilerChunkCount++;
	return true;
}

void FinishProfilerResult(bool success)
{
	bool direct = g_bProfilerDirectOutput;
	char sourcePath[PLATFORM_MAX_PATH];
	strcopy(sourcePath, sizeof(sourcePath), g_sProfilerSourcePath);

	delete g_hProfilerSourceFile;
	delete g_hProfilerLogFile;
	g_bProfilerResultWriting = false;

	if( direct )
	{
		if( success )
		{
			g_hProfilerLogger.info("VPROF_RESULT_END source=direct chunks=%d truncated=0", g_iProfilerChunkCount);
		}
		else {
			g_hProfilerLogger.warning("VPROF_RESULT_END source=direct chunks=%d failed=1", g_iProfilerChunkCount);
		}
	}
	else {
		if( success )
		{
			g_hProfilerLogger.info("VPROF_RESULT_END path=%s chunks=%d", sourcePath, g_iProfilerChunkCount);
		}
		else {
			g_hProfilerLogger.warning("VPROF_RESULT_END path=%s chunks=%d failed=1", sourcePath, g_iProfilerChunkCount);
		}
	}

	if( !g_bL4D2 )
	{
		SetCvarSilent(g_CVarLogFile, g_PathOrig);
	}
	g_hTimer = null;
	g_bProfilerDirectOutput = false;
	g_sProfilerSourcePath[0] = '\0';
}

public void OnFrameWriteProfilerOutput()
{
	if( !g_bProfilerResultWriting || !g_bProfilerDirectOutput ) return;

	char sChunk[MAX_LOG_LINE];
	int chunksThisFrame;
	while( g_iProfilerOutputOffset < g_iProfilerOutputLength && chunksThisFrame < VPROF_CHUNKS_PER_FRAME )
	{
		int chunkLength = g_iProfilerOutputLength - g_iProfilerOutputOffset;
		if( chunkLength > MAX_LOG_LINE - 1 )
		{
			chunkLength = MAX_LOG_LINE - 1;
		}

		for( int i = 0; i < chunkLength; i++ )
		{
			sChunk[i] = g_sProfilerOutput[g_iProfilerOutputOffset + i];
		}
		if( !WriteProfilerChunk(sChunk, chunkLength) )
		{
			FinishProfilerResult(false);
			return;
		}
		g_iProfilerOutputOffset += chunkLength;
		chunksThisFrame++;
	}

	if( g_iProfilerOutputOffset < g_iProfilerOutputLength )
	{
		RequestFrame(OnFrameWriteProfilerOutput);
		return;
	}

	if( g_iProfilerOutputLength > 0 && g_sProfilerOutput[g_iProfilerOutputLength - 1] != '\n' )
	{
		if( !g_hProfilerLogger.WriteRawString(g_hProfilerLogFile, "\n") )
		{
			FinishProfilerResult(false);
			return;
		}
	}
	FinishProfilerResult(true);
}

bool WriteProfilerOutputToLogger(const char[] output)
{
	int outputLength = strlen(output);
	if( outputLength == 0 )
	{
		g_hProfilerLogger.warning("VPROF_RESULT_CAPTURE_EMPTY");
		return false;
	}

	bool truncated = (outputLength >= VPROF_CAPTURE_MAX_BYTES - 1);
	if( truncated )
	{
		g_hProfilerLogger.warning("VPROF_RESULT_CAPTURE_TRUNCATED bytes=%d max=%d", outputLength, VPROF_CAPTURE_MAX_BYTES - 1);
		return false;
	}

	g_hProfilerLogger.info("VPROF_RESULT_BEGIN source=direct bytes=%d", outputLength);
	g_hProfilerLogFile = g_hProfilerLogger.OpenRawFile();
	if( g_hProfilerLogFile == null )
	{
		g_hProfilerLogger.error("VPROF_RESULT_OPEN_FAIL");
		return false;
	}

	g_iProfilerOutputLength = outputLength;
	g_iProfilerOutputOffset = 0;
	g_iProfilerChunkCount = 0;
	g_bProfilerResultWriting = true;
	g_bProfilerDirectOutput = true;
	g_bProfilerSourceHasBytes = false;
	g_bProfilerSourceEndsWithNewline = true;
	g_sProfilerSourcePath[0] = '\0';
	RequestFrame(OnFrameWriteProfilerOutput);
	return true;
}

public Action Timer_RestoreCvar(Handle timer)
{
	AppendProfilerResultToLogger(g_PathProfilerLog);
	g_hTimer = null;
	return Plugin_Stop;
}

public Action Timer_MirrorLog(Handle timer, int init)
{
	static float sec;
	
	if( init ) sec = 0.0;
	sec += LOG_CHECK_INTERVAL;
	
	if( sec > LOG_MAX_WAITTIME )
	{
		g_hTimer = null;
		if( FileSize(g_PathCosole) != g_ptrFile )
		{
			StartMirrorCopy();
		}
		else {
			StartMirrorProfilerLog();
		}
		return Plugin_Stop;
	}
	if( FileSize(g_PathCosole) != g_ptrFile )
	{
		g_hTimer = null;
		StartMirrorCopy();
		return Plugin_Stop;
	}
	g_hTimer = CreateTimer(LOG_CHECK_INTERVAL, Timer_MirrorLog, 0);
	return Plugin_Continue;
}

void StartMirrorCopy()
{
	if( g_bMirrorCopying ) return;

	delete g_hMirrorSourceFile;
	delete g_hMirrorTargetFile;
	g_hMirrorSourceFile = OpenFile(g_PathCosole, "rb");
	if( !g_hMirrorSourceFile )
	{
		LogError("Cannot open file: %s", g_PathCosole);
		StartMirrorProfilerLog();
		return;
	}
	if( g_ptrFile != -1 )
	{
		g_hMirrorSourceFile.Seek(g_ptrFile, SEEK_SET);
	}
	g_iMirrorOffset = g_hMirrorSourceFile.Position;
	g_hMirrorTargetFile = OpenFile(g_PathProfilerLog, "ab");
	if( !g_hMirrorTargetFile )
	{
		LogError("Cannot open file: %s", g_PathProfilerLog);
		delete g_hMirrorSourceFile;
		StartMirrorProfilerLog();
		return;
	}
	g_bMirrorCopying = true;
	RequestFrame(OnFrameMirrorLog);
}

public void OnFrameMirrorLog()
{
	if( !g_bMirrorCopying ) return;

	int copied;
	int bytesRead;
	int buff[1024];
	while( copied < VPROF_MIRROR_BYTES_PER_FRAME && !g_hMirrorSourceFile.EndOfFile() )
	{
		int requested = sizeof(buff);
		if( requested > VPROF_MIRROR_BYTES_PER_FRAME - copied )
		{
			requested = VPROF_MIRROR_BYTES_PER_FRAME - copied;
		}
		bytesRead = g_hMirrorSourceFile.Read(buff, requested, 1);
		if( bytesRead < 0 )
		{
			delete g_hMirrorSourceFile;
			delete g_hMirrorTargetFile;
			g_bMirrorCopying = false;
			StartMirrorProfilerLog();
			return;
		}
		if( bytesRead == 0 )
		{
			if( !g_hMirrorSourceFile.EndOfFile() )
			{
				delete g_hMirrorSourceFile;
				delete g_hMirrorTargetFile;
				g_bMirrorCopying = false;
				g_hProfilerLogger.error("VPROF_MIRROR_READ_FAIL path=%s", g_PathCosole);
				StartMirrorProfilerLog();
				return;
			}
			break;
		}
		if( !g_hMirrorTargetFile.Write(buff, bytesRead, 1) )
		{
			delete g_hMirrorSourceFile;
			delete g_hMirrorTargetFile;
			g_bMirrorCopying = false;
			StartMirrorProfilerLog();
			return;
		}
		copied += bytesRead;
		g_iMirrorOffset += bytesRead;
	}

	if( !g_hMirrorSourceFile.EndOfFile() )
	{
		RequestFrame(OnFrameMirrorLog);
		return;
	}

	g_ptrFile = g_iMirrorOffset;
	delete g_hMirrorSourceFile;
	delete g_hMirrorTargetFile;
	g_bMirrorCopying = false;
	StartMirrorProfilerLog();
}

void StartMirrorProfilerLog()
{
	AppendProfilerResultToLogger(g_PathProfilerLog);
}

public void OnFrameAppendProfilerResult()
{
	if( !g_bProfilerResultWriting || g_bProfilerDirectOutput ) return;

	char sChunk[MAX_LOG_LINE];
	int chunksThisFrame;
	bool atEnd;
	while( chunksThisFrame < VPROF_CHUNKS_PER_FRAME )
	{
		int bytesRead = g_hProfilerSourceFile.ReadString(sChunk, MAX_LOG_LINE, MAX_LOG_LINE - 1);
		if( bytesRead < 0 )
		{
			FinishProfilerResult(false);
			return;
		}
		if( bytesRead == 0 )
		{
			atEnd = true;
			break;
		}

		sChunk[bytesRead] = '\0';
		if( !WriteProfilerChunk(sChunk, bytesRead) )
		{
			FinishProfilerResult(false);
			return;
		}
		g_bProfilerSourceHasBytes = true;
		g_bProfilerSourceEndsWithNewline = (sChunk[bytesRead - 1] == '\n');
		chunksThisFrame++;
	}

	if( !atEnd )
	{
		RequestFrame(OnFrameAppendProfilerResult);
		return;
	}

	if( g_bProfilerSourceHasBytes && !g_bProfilerSourceEndsWithNewline )
	{
		if( !g_hProfilerLogger.WriteRawString(g_hProfilerLogFile, "\n") )
		{
			FinishProfilerResult(false);
			return;
		}
	}
	FinishProfilerResult(true);
}

void AppendProfilerResultToLogger(const char[] sourcePath)
{
	g_hProfilerSourceFile = OpenFile(sourcePath, "rb");
	if( !g_hProfilerSourceFile )
	{
		g_hProfilerLogger.error("VPROF_RESULT_READ_FAIL path=%s", sourcePath);
		if( !g_bL4D2 )
		{
			SetCvarSilent(g_CVarLogFile, g_PathOrig);
		}
		return;
	}

	g_hProfilerLogger.info("VPROF_RESULT_BEGIN path=%s", sourcePath);
	g_hProfilerLogFile = g_hProfilerLogger.OpenRawFile();
	if( g_hProfilerLogFile == null )
	{
		delete g_hProfilerSourceFile;
		if( !g_bL4D2 )
		{
			SetCvarSilent(g_CVarLogFile, g_PathOrig);
		}
		return;
	}

	strcopy(g_sProfilerSourcePath, sizeof(g_sProfilerSourcePath), sourcePath);
	g_iProfilerChunkCount = 0;
	g_bProfilerResultWriting = true;
	g_bProfilerDirectOutput = false;
	g_bProfilerSourceHasBytes = false;
	g_bProfilerSourceEndsWithNewline = true;
	RequestFrame(OnFrameAppendProfilerResult);
}
