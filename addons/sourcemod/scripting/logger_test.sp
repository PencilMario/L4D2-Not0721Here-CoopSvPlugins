#include <sourcemod>
#include <logger>
Logger log;
Logger log2
public void OnPluginStart(){
    log = new Logger("loggertest_SourcemodLog");
    log2 = new Logger("loggertest_NewLog", LoggerType_NewLogFile);

    log.lograw("Logger_test_SourcemodLog raw");
    log.debug("Logger_test_SourcemodLog debug");
    log.info("Logger_test_SourcemodLog info");
    log.warning("Logger_test_SourcemodLog warning");
    log.error("Logger_test_SourcemodLog error");
    log.critical("Logger_test_SourcemodLog critical");

    log2.IgnoreLevel = LogType_Debug;

    log2.lograw("Logger_test_NewLog raw");
    log2.debug("Logger_test_NewLog debug");
    log2.info("Logger_test_NewLog info");
    log2.warning("Logger_test_NewLog warning");
    log2.error("Logger_test_NewLog error");
    log2.critical("Logger_test_NewLog critical");

    log2.lograw("!!Logger_test_NewLog IgnoreLevel set to Warning!!");
    log2.IgnoreLevel = LogType_Warning;
    log2.debug("Logger_test_NewLog debug");
    log2.info("Logger_test_NewLog info");
    log2.warning("Logger_test_NewLog warning");
    log2.error("Logger_test_NewLog error");
    log2.critical("Logger_test_NewLog critical");

    log2.IgnoreLevel = LogType_Info;
    log2.lograw("!!Format test!!");
    log2.info("index: %i", log2.index);

    log2.lograw("!!Prefix test!!");
    log2.SetLogPrefix("[test]");
    log2.info("Prefix test");
}

