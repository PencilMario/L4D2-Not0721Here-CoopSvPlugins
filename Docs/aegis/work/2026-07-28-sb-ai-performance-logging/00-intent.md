# Intent

Record only slow Survivor Bot AI calculations through logger.inc. Logging is disabled by default, writes to logs/sb_ai_performance.log, and must not impose timer overhead while disabled.

Compatibility boundary: preserve hot-path signatures, arguments, return values, and calculation bodies.
