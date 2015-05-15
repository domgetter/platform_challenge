require "logger"
require "awesome_print"
require "byebug"

# create constant logger
$logger = Logger.new(STDOUT)
$logger.level = Logger::FATAL
