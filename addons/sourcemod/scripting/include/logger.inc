/*
 * @Author: 夜羽真白
 * @Date: 2023-05-23 00:03 周二
 * @Type: Left 4 Dead 2 Plugin
 * @Description: 日志记录对象
 * @URL: https://github.com/GlowingTree880/L4D2_LittlePlugins
 */

#if defined _logger_included
 #endinput
#endif
#define _logger_included

#if !defined LOGGER_NAME
 #define LOGGER_NAME "Logger"
#endif



enum LoggerType{
    LoggerType_SourcemodLog = 0,
    LoggerType_NewLogFile,
    LoggerType_Size
};

enum LogType {
    LogType_Debug = 0,
    LogType_Info,
    LogType_Warning,
    LogType_Error,
    LogType_Critical,
    LogType_Size
}

char LogTypeStr[LogType_Size][] = {
    "Debug",
    "Info",
    "Warning",
    "Error",
    "Critical"
}

methodmap Logger __nullable__
{

    public Logger(LoggerType LogObjectType = LoggerType_SourcemodLog)
    {
        return view_as<Logger>(LogObjectType);
    }

    
    public void debug(const char[] message, any ...)
    {
        char buffer[512];
        VFormat(buffer, sizeof(buffer), message, 3);
        if (this.LogObjectType == LoggerType_NewLogFile) this.WritetoLogFile(LogType_Debug, message)
        else LogMessage(buffer);
    }

    public void info(const char[] message, any ...)
    {
        char buffer[512];
        VFormat(buffer, sizeof(buffer), message, 3);
        if (this.LogObjectType == LoggerType_NewLogFile) this.WritetoLogFile(LogType_Info, message)
        else LogMessage(buffer);
    }

    public void warning(const char[] message, any ...)
    {
        char buffer[512];
        VFormat(buffer, sizeof(buffer), message, 3);
        PrintToServer(buffer);
        if (this.LogObjectType == LoggerType_NewLogFile) this.WritetoLogFile(LogType_Warning, message)
        else LogError(buffer);
    }  

    public void error(const char[] message, any ...)
    {
        char buffer[512];
        VFormat(buffer, sizeof(buffer), message, 3);
        PrintToServer(buffer);
        if (this.LogObjectType == LoggerType_NewLogFile) this.WritetoLogFile(LogType_Error, message)
        else LogError(buffer);
    }    

    public void critical(const char[] message, any ...)
    {
        char buffer[512];
        VFormat(buffer, sizeof(buffer), message, 3);
        PrintToServer(buffer);
        if (this.LogObjectType == LoggerType_NewLogFile) this.WritetoLogFile(LogType_Critical, message)
        else LogError(buffer);
    }
    property LoggerType LogObjectType
    {
        public get() { return view_as<LoggerType>(this); }
    }
    
    public void WritetoLogFile(LogType logtype, const char[] message, any ...)
    {
        char logpath[160];
        //char buffer[512];
        BuildPath(Path_SM, logpath, sizeof(logpath), "logs/%s.log", LOGGER_NAME);
        Handle file = OpenFile(logpath, "at");

        if (file == null) {
            PrintToServer("[logger] 无法打开文件：%s", logpath);
            LogError("[logger] 无法打开文件：%s", logpath);
            return;
        }

        char time[64];
        FormatTime(time, sizeof(time), "%Y-%m-%d %H:%M:%S", GetTime());
        WriteFileLine(file, "[%s] [%s]: %s", time, LogTypeStr[logtype], message);
        CloseHandle(file);
    }
}