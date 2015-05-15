#!/usr/bin/env ruby
# encoding: utf-8

require "rake"
require "oauth"
require "json"
require "net/http"
require "http_logger"
require 'logger'
require "awesome_print"
require "pry"
require "byebug"

require "logger"
require_relative "./hashtag_data"
require_relative "./http_server"
require_relative "./service_manager"
require_relative "./stream_twitter"

task :default => :start

task :start do
  $logger = Logger.new(STDOUT)
  $logger.level = Logger::DEBUG

  hashtag_data = HashtagData.new
  stream_twitter = StreamTwitter.new(hashtag_data)
  http_server = HttpServer.new(hashtag_data)

  service_manager = ServiceManager.new(hashtag_data)
  service_manager.add_thread(Thread.new { http_server.start })
  service_manager.add_thread(Thread.new { stream_twitter.start })
  service_manager.start
end
