require "awesome_print"
require "oauth"
require "json"
require 'net/http'
require 'http_logger'
require 'pry'
require 'byebug'

HttpLogger.colorize = true
HttpLogger.level = :debug

def sign_request(req, params)
  consumer = OAuth::Consumer.new(
    params.fetch(:consumer_key),
    params.fetch(:consumer_secret),
    { :site => "https://stream.twitter.com", :scheme => :header }
  )

  # now create the access token object from passed values
  token_hash = {
    :oauth_token => params.fetch(:access_token),
    :oauth_token_secret => params.fetch(:access_token_secret)
  }

  access_token = OAuth::AccessToken.from_hash(consumer, token_hash)

  access_token.sign!(req)
end

def json_parse(data)
  parsed_data = JSON.parse(data)
  # ap parsed_data
  if parsed_data["text"]
    ap parsed_data["text"]
    # ap parsed_data["hashtags"]
    # ap parsed_data
    # /\b#\w\w+/.match(parsed_data["text"])
  else
    ap parsed_data
  end
end

# need to create a twitter app
# https://apps.twitter.com/

params = {
  :consumer_key       => 'CHANGE consumer_key',
  :consumer_secret    => 'CHANGE consumer_secret',
  :access_token        => 'CHANGE access_token',
  :access_token_secret => 'CHANGE access_token_secret'
}

site = "https://stream.twitter.com/1.1/statuses/sample.json"

uri = URI.parse(site)

http_object = Net::HTTP.new(uri.host, uri.port)

# http_object.set_debug_output $stderr
http_object.use_ssl = true
http_object.verify_mode = OpenSSL::SSL::VERIFY_NONE
http_object.read_timeout = 30

request = Net::HTTP::Get.new(site, {})

# access_token.sign!(request)
sign_request(request, params)

# abc1abc1abc1a
# abc, abc, abc, a len = 4

# bc1ab
# bc, ab len = 2

# ab
# ab len = 1


http_object.request request do |response|
  prev = nil
  response.read_body do |chunk|
    parts = chunk.split("\r\n")
    puts parts.count
    if parts.length == 1
      if prev != nil
        prev += parts[0]
      end
    elsif parts.length == 2
      if prev != nil
        prev += parts[0]
        json_parse(prev)
      end
      prev = parts[1]
    else
      parts.each_with_index do |part, index|
        if index == 0
          if prev != nil
            prev += part
            json_parse(prev)
          end
        elsif index == parts.length - 1
          prev = part
        else
          json_parse(part)
        end
      end
    end
    # the first time parts[0] is invalid
    # always save parts[-1] for the next go round

    # parse everything in between
    # prev += parts[0]

  end
end

http_object.finish


