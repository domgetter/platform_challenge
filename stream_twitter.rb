# encoding: utf-8
require "json"

class StreamTwitter
  TWITTER_STREAM_URI = "https://stream.twitter.com/1.1/statuses/sample.json"

  def initialize(hashtag_data)
    @hashtag_data = hashtag_data
    @current_tweet = nil

    self.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
    self.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
    self.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
    self.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
  end

  def sign_request(req, params)
    consumer = OAuth::Consumer.new(
      params.fetch(:consumer_key),
      params.fetch(:consumer_secret),
      {
        :site => "https://stream.twitter.com", :scheme => :header
      }
    )

    token_hash = {
      :oauth_token => params.fetch(:access_token),
      :oauth_token_secret => params.fetch(:access_token_secret)
    }

    access_token = OAuth::AccessToken.from_hash(consumer, token_hash)

    access_token.sign!(req)
  end

  class HupException < Exception; end;

  def start_http_request
    # HttpLogger.colorize = true
    # HttpLogger.level = :debug

    params = {
      :consumer_key        => consumer_key,
      :consumer_secret     => consumer_secret,
      :access_token        => access_token,
      :access_token_secret => access_token_secret
    }

    uri = URI.parse(TWITTER_STREAM_URI)

    http_object = Net::HTTP.new(uri.host, uri.port)

    # http_object.set_debug_output $stderr
    http_object.use_ssl = true
    http_object.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http_object.read_timeout = 30

    begin
      request = Net::HTTP::Get.new(TWITTER_STREAM_URI)

      sign_request(request, params)

      http_object.request request do |response|
        response.read_body do |chunk|
          parse_chunk(chunk)

          if Thread.current[:hup] == true || Thread.current[:quit] == true
            @current_tweet = nil
            raise HupException.new
          end
        end
      end

      http_object.finish
    rescue HupException
    end
  end

  def start
    start_http_request

    while Thread.current[:hup] == true
      Thread.current[:hup] = false
      start_http_request
    end

    if Thread.current[:quit] == true
      exit
    end
  end

  def json_parse(data)
    begin
      parsed_data = JSON.parse(data)
      if parsed_data["text"]
        if parsed_data["entities"] && parsed_data["entities"]["hashtags"].any?

          # http://stackoverflow.com/questions/12102746/regex-to-match-hashtags-in-a-sentence-using-ruby
          # this regex didn't work for non english languages
          # was much easier to use the existing hashtags provided by the stream
          # hashtags = parsed_data["text"].scan(/(?:\s|^)(?:#(?!(?:\d+|\w+?_|_\w+?)(?:\s|$)))(\w+)(?=\s|$)/i).flatten

          parsed_data["entities"]["hashtags"].each do |hashtag|
            if hashtag["text"]
              $logger.debug(hashtag["text"])
              @hashtag_data.add_hashtag(hashtag["text"])
            end
          end
        end
      end
    rescue JSON::ParserError => e
      $logger.debug(e.inspect)
    end
  end

  def parse_chunk(chunk)
    parts = chunk.split("\r\n")
    # if we only have one in the stream
    # that means that we don't have a full one yet
    if parts.length == 1
      # we don't have a full tweet so only start saving the tweet if it exists
      if @current_tweet != nil
        @current_tweet += parts[0]
      end
    # if we have two parts then we have a part of the previous tweet and part of the next tweet
    # if we don't have a previous tweet then just throw away the
    elsif parts.length == 2
      if @current_tweet != nil
        @current_tweet += parts[0]
        json_parse(@current_tweet)
        @current_tweet = parts[1]
      else
        @current_tweet = parts[1]
      end
    # if we have mulitple parts then start parsing them for each tweet
    else
      parts.each_with_index do |part, index|
        if index == 0
          if @current_tweet != nil
            @current_tweet += part
            json_parse(@current_tweet)
          end
        elsif index == parts.length - 1
          @current_tweet = part
        else
          @current_tweet = part
          json_parse(@current_tweet)
        end
      end
    end
  end

  private

  attr_accessor :current_tweet, :consumer_key, :consumer_secret, :access_token, :access_token_secret
end
