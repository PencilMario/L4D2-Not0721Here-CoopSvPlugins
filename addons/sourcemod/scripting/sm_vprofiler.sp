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
const int VPROF_CAPTURE_MAX_BYTES = 1048576;

char g_sProfilerOutput[VPROF_CAPTURE_MAX_BYTES];
char 	g_PathPrefix[PLATFORM_MAX_PATH],
		g_PathProfilerLogger[PLATFORM_MAX_PATH],
		g_PathOrig[PLATFORM_MAX_PATH],
		g_PathProfilerLog[PLATFORM_MAX_PATH],
		g_PathCosole[] = "console.log";
ConVar 	g_CVarLogFile;
Handle 	g_hTimer;
Logger g_hProfilerLogger;
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

public void OnConfigsExecuted()
{
	g_CVarLogFile.GetString(g_PathOrig, sizeof(g_PathOrig));
}

public Action Cmd_Debug(int client, int args)
{
	static bool start;
	char sTime[32];
	
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
		ServerCommand("sm prof stop vprof");
		ServerCommandEx(g_sProfilerOutput, sizeof(g_sProfilerOutput), "sm prof dump vprof");
		ServerCommand("vprof_off");
		ServerExecute();
		ReplyToCommand(client, "\x04[STOP]\x05 Profiler result written to: %s", g_PathProfilerLogger);

		// Capture directly first. The file path remains a fallback for engines or
		// reports that do not fit in ServerCommandEx's output buffer.
		if( WriteProfilerOutputToLogger(g_sProfilerOutput) )
		{
			if( !g_bL4D2 )
			{
				SetCvarSilent(g_CVarLogFile, g_PathOrig);
			}
			g_hTimer = null;
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
	start = !start;
	return Plugin_Handled;
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

void WriteProfilerChunk(char[] sChunk, int length, int &chunkCount)
{
	sChunk[length] = '\0';
	g_hProfilerLogger.lograw("%s", sChunk);
	chunkCount++;
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
	char sChunk[MAX_LOG_LINE];
	int chunkLength = 0;
	int chunkCount = 0;

	for( int i = 0; i < outputLength; i++ )
	{
		if( output[i] == '\r' )
		{
			continue;
		}
		if( output[i] == '\n' )
		{
			WriteProfilerChunk(sChunk, chunkLength, chunkCount);
			chunkLength = 0;
			continue;
		}
		if( chunkLength >= MAX_LOG_LINE - 1 )
		{
			WriteProfilerChunk(sChunk, chunkLength, chunkCount);
			chunkLength = 0;
		}
		sChunk[chunkLength++] = output[i];
	}
	if( chunkLength > 0 )
	{
		WriteProfilerChunk(sChunk, chunkLength, chunkCount);
	}

	g_hProfilerLogger.info("VPROF_RESULT_END source=direct chunks=%d truncated=%d", chunkCount, truncated);
	return !truncated;
}

public Action Timer_RestoreCvar(Handle timer)
{
	AppendProfilerResultToLogger(g_PathProfilerLog);
	SetCvarSilent(g_CVarLogFile, g_PathOrig);
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
		AppendProfilerResultToLogger(g_PathProfilerLog);
		g_hTimer = null;
		return Plugin_Stop;
	}
	if( FileSize(g_PathCosole) != g_ptrFile )
	{
		File hr = OpenFile(g_PathCosole, "rb");
		if( !hr )
		{
			LogError("Cannot open file: %s", g_PathCosole);
			g_hTimer = null;
			return Plugin_Stop;
		}
		if( g_ptrFile != -1 )
		{
			hr.Seek(g_ptrFile, SEEK_SET);
		}
		File hw = OpenFile(g_PathProfilerLog, "ab");	
		if( hw )
		{
			static int bytesRead, buff[1024];
			
			while( !hr.EndOfFile() )
			{
				bytesRead = hr.Read(buff, sizeof(buff), 1);
				hw.Write(buff, bytesRead, 1);
			}
			delete hw;
		}
		g_ptrFile = hr.Position;
		delete hr;
	}
	g_hTimer = CreateTimer(LOG_CHECK_INTERVAL, Timer_MirrorLog, 0);
	return Plugin_Continue;
}

void AppendProfilerResultToLogger(const char[] sourcePath)
{
	File file = OpenFile(sourcePath, "rt");
	if( !file )
	{
		g_hProfilerLogger.error("VPROF_RESULT_READ_FAIL path=%s", sourcePath);
		return;
	}

	g_hProfilerLogger.info("VPROF_RESULT_BEGIN path=%s", sourcePath);
	char sChunk[MAX_LOG_LINE];
	while( ReadFileLine(file, sChunk, sizeof(sChunk)) )
	{
		g_hProfilerLogger.lograw("%s", sChunk);
	}
	delete file;
	g_hProfilerLogger.info("VPROF_RESULT_END path=%s", sourcePath);
}
