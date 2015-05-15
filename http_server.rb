# encoding: utf-8
require "webrick"
require_relative "./hashtag_data"

class HttpServer
  def initialize(hashtag_data)
    @hashtag_data = hashtag_data
    @server = nil
  end

  def start
    $logger.info("starting webbrick")

    @server = WEBrick::HTTPServer.new :Port => 8000
    @server.mount_proc '/' do |request, response|
      response.set_redirect WEBrick::HTTPStatus[301], "/top10"
    end

    @server.mount_proc '/top10' do |request, response|
      response.status = 200
      response['Content-Type'] = 'application/json'
      response['Charset'] = 'utf-8'
      response.body = @hashtag_data.top_ten
    end

    @server.mount_proc '/debug' do |request, response|
      response.status = 200
      response['Content-Type'] = 'application/json'
      response.body = @hashtag_data.debug
    end

    @server.start
  end
end
