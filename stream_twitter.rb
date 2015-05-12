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

# rotating hashtags
$HASHTAGS = 7.times.map { Hash.new(0) }
$CURRENT_HASH_INDEX = 0
$TIME_START = Time.now.to_i
$TIME_SHOW = Time.now.to_i


def json_parse(data)
  parsed_data = JSON.parse(data)
  # ap parsed_data
  if parsed_data["text"]
    # http://stackoverflow.com/questions/12102746/regex-to-match-hashtags-in-a-sentence-using-ruby
    hashtags = parsed_data["text"].scan(/(?:\s|^)(?:#(?!(?:\d+|\w+?_|_\w+?)(?:\s|$)))(\w+)(?=\s|$)/i).flatten
    if hashtags.any?
      hashtags.each do |match|
        $HASHTAGS[$CURRENT_HASH_INDEX][match.downcase] += 1

        if Time.now.to_i > $TIME_START + 10
          $CURRENT_HASH_INDEX = ($CURRENT_HASH_INDEX + 1) % $HASHTAGS.length
          ap "----------------- current index = #{$CURRENT_HASH_INDEX}"
          $HASHTAGS[$CURRENT_HASH_INDEX].clear
          $TIME_START = Time.now.to_i
        end

        if Time.now.to_i > $TIME_SHOW + 5

          all_hash = Hash.new(0)
          $HASHTAGS.each do |hashtag|
            hashtag.each do |key, value|
              all_hash[key] += value
            end
          end
          ap all_hash.sort_by {|key, value| value }.reverse[1..10]
          $TIME_SHOW = Time.now.to_i
        end
      end
    end
  end
end

# need to create a twitter app
# https://apps.twitter.com/

params = {
  :consumer_key       => ENV["TWITTER_CONSUMER_KEY"],
  :consumer_secret    => ENV["TWITTER_CONSUMER_SECRET"],
  :access_token        => ENV["TWITTER_ACCESS_TOKEN"],
  :access_token_secret => ENV["TWITTER_ACCESS_TOKEN_SECRET"]
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

begin

  to_parse = nil

  http_object.request request do |response|
    response.read_body do |chunk|
      parts = chunk.split("\r\n")
      # puts parts.count
      if parts.length == 1
        if prev != nil
          prev += parts[0]
        end
      elsif parts.length == 2
        if prev != nil
          prev += parts[0]

          to_parse = prev
          json_parse(to_parse)
        end
        prev = parts[1]
      else
        parts.each_with_index do |part, index|
          if index == 0
            if prev != nil
              prev += part

              to_parse = prev
              json_parse(to_parse)
            end
          elsif index == parts.length - 1
            prev = part
          else
            to_parse = part
            json_parse(to_parse)
          end
        end
      end
      # the first time parts[0] is invalid
      # always save parts[-1] for the next go round

      # parse everything in between
      # prev += parts[0]


    end
  end

rescue JSON::ParserError => e
  ap e
  ap to_parse
end


http_object.finish


