/*
 * @Author: 夜羽真白/Sir.P
 * @Date: 2023-05-23 00:03 周二
 * @Type: Left 4 Dead 2 Plugin
 * @Description: 日志记录对象
 * @URL: https://github.com/GlowingTree880/L4D2_LittlePlugins & https://github.com/PencilMario/L4D2-Not0721Here-CoopSvPlugins
 */

/**
 * 使用方法与原版有一些区别：
 * 在引用头文件前，需要define log的名称（决定了保存的log文件）（只限于LoggerType_NewLogFile）
 * 在new Logger时，可以不传变量，也可以传入LoggerType
 * 可在 https://github.com/PencilMario/L4D2-Not0721Here-CoopSvPlugins/blob/main/addons/sourcemod/scripting/logger_test.sp 查看示例
 */

#if defined _logger_included
 #endinput
#endif
#define _logger_included

#if !defined LOGGER_NAME
 #define LOGGER_NAME "Logger"
#endif



enum LoggerType{
    // 保存在log/L********.log，默认
    LoggerType_SourcemodLog = 0,
    // 保存在log/[LOGGER_NAME].log
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

    public void lograw(const char[] message, any ...)
    {
        char buffer[512];
        VFormat(buffer, sizeof(buffer), message, 3);
        if (this.LogObjectType == LoggerType_NewLogFile) this.WritetoLogFileRaw(message)
        else LogMessage(buffer);
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

    public void WritetoLogFileRaw(const char[] message, any ...)
    {
        char logpath[160];
        BuildPath(Path_SM, logpath, sizeof(logpath), "logs/%s.log", LOGGER_NAME);
        Handle file = OpenFile(logpath, "at");

        if (file == null) {
            PrintToServer("[logger] 无法打开文件：%s", logpath);
            LogError("[logger] 无法打开文件：%s", logpath);
            return;
        }

        WriteFileLine(file, "%s", message);
        CloseHandle(file);
    }
}