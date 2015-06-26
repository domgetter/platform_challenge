require_relative "./spec_helper"
require_relative "../models/stream_twitter"
require_relative "../models/hashtag_data"

RSpec.describe StreamTwitter do
  describe "#extract_tweets" do
    it "does not try to parse chunk if it doesn't have a delimiter" do
      hashtag_data = HashtagData.new
      stream_twitter = StreamTwitter.new(hashtag_data)
      expect(stream_twitter).to receive(:json_parse).never

      stream_twitter.extract_tweets("{\"123")
    end

    it "handles an empty chunk" do
      hashtag_data = HashtagData.new
      stream_twitter = StreamTwitter.new(hashtag_data)

      expect(stream_twitter).to receive(:json_parse).with("{\"123\":\"456\"}").twice

      stream_twitter.extract_tweets("")
      stream_twitter.extract_tweets("{\"123\"")
      stream_twitter.extract_tweets(":\"456\"}\r\n{\"123\"")
      stream_twitter.extract_tweets(":\"456\"}\r\n{\"123\"")

    end

    it "calls json_parse twice if the chunk has two parts" do
      hashtag_data = HashtagData.new
      stream_twitter = StreamTwitter.new(hashtag_data)

      expect(stream_twitter).to receive(:json_parse).with("{\"123\":\"456\"}").twice

      stream_twitter.extract_tweets("")
      stream_twitter.extract_tweets("{\"123\"")
      stream_twitter.extract_tweets(":\"456\"}\r\n{\"123\"")
      stream_twitter.extract_tweets(":\"456\"}\r\n{\"123\"")

    end

    it "calls json_parse twice if the chunk has two parts and \\r\\n is split up" do
      hashtag_data = HashtagData.new
      stream_twitter = StreamTwitter.new(hashtag_data)

      expect(stream_twitter).to receive(:json_parse).with("{\"123\":\"456\"}").twice

      stream_twitter.extract_tweets("{\"123\":\"456\"}\r")
      stream_twitter.extract_tweets("\n{\"123\"")
      stream_twitter.extract_tweets(":\"456\"}\r\n{\"123\"")

    end

    it "calls json_parse twice if the chunk has two parts and \\r\\n starts a chunk" do
      hashtag_data = HashtagData.new
      stream_twitter = StreamTwitter.new(hashtag_data)

      expect(stream_twitter).to receive(:json_parse).with("{\"123\":\"456\"}").twice

      stream_twitter.extract_tweets("{\"123\":\"456\"}")
      stream_twitter.extract_tweets("\r\n{\"123\"")
      stream_twitter.extract_tweets(":\"456\"}\r\n{\"123\"")

    end

    it "calls json_parse twice if the chunk has two parts and \\r\\n ends a chunk" do
      hashtag_data = HashtagData.new
      stream_twitter = StreamTwitter.new(hashtag_data)

      expect(stream_twitter).to receive(:json_parse).with("{\"123\":\"456\"}").twice

      stream_twitter.extract_tweets("{\"123\":\"456\"}\r\n")
      stream_twitter.extract_tweets("{\"123\"")
      stream_twitter.extract_tweets(":\"456\"}\r\n{\"123\"")

    end

    it "calls json_parse 4 times when chunk has multiple parts" do
      hashtag_data = HashtagData.new
      stream_twitter = StreamTwitter.new(hashtag_data)

      expect(stream_twitter).to receive(:json_parse).with("{\"123\":\"456\"}").exactly(3).times
      stream_twitter.extract_tweets("{\"123\":\"456\"}\r\n{\"123\":\"456\"}\r\n{\"123\":\"456\"}\r\n{\"123\"")
    end
  end

  describe "#json_parse" do
    it "adds the hashtags" do
      hashtag_data = HashtagData.new
      stream_twitter = StreamTwitter.new(hashtag_data)
      stream_twitter.json_parse("{\"created_at\":\"Fri May 15 04:46:10 +0000 2015\",\"id\":599073262442774528,\"id_str\":\"599073262442774528\",\"text\":\"Tourism NZ moves away from hobbits in new campaign http:\\/\\/t.co\\/4WAWxmNBCd #tourism #travelnews\",\"source\":\"\\u003ca href=\\\"http:\\/\\/bufferapp.com\\\" rel=\\\"nofollow\\\"\\u003eBuffer\\u003c\\/a\\u003e\",\"truncated\":false,\"in_reply_to_status_id\":null,\"in_reply_to_status_id_str\":null,\"in_reply_to_user_id\":null,\"in_reply_to_user_id_str\":null,\"in_reply_to_screen_name\":null,\"user\":{\"id\":71128740,\"id_str\":\"71128740\",\"name\":\"Intl Travel College\",\"screen_name\":\"itcnz\",\"location\":\"Auckland\",\"url\":\"http:\\/\\/www.itc.co.nz\",\"description\":\"The International Travel College of New Zealand is a premium supplier of travel, tourism, airline & aviation training | Tweets by @ClaireLHuxley & @jess_oconnor\",\"protected\":false,\"verified\":false,\"followers_count\":936,\"friends_count\":1089,\"listed_count\":36,\"favourites_count\":133,\"statuses_count\":2127,\"created_at\":\"Thu Sep 03 00:56:35 +0000 2009\",\"utc_offset\":43200,\"time_zone\":\"Auckland\",\"geo_enabled\":false,\"lang\":\"en\",\"contributors_enabled\":false,\"is_translator\":false,\"profile_background_color\":\"9AE4E8\",\"profile_background_image_url\":\"http:\\/\\/pbs.twimg.com\\/profile_background_images\\/34063158\\/ITC371.jpg\",\"profile_background_image_url_https\":\"https:\\/\\/pbs.twimg.com\\/profile_background_images\\/34063158\\/ITC371.jpg\",\"profile_background_tile\":true,\"profile_link_color\":\"0084B4\",\"profile_sidebar_border_color\":\"BDDCAD\",\"profile_sidebar_fill_color\":\"DDFFCC\",\"profile_text_color\":\"333333\",\"profile_use_background_image\":true,\"profile_image_url\":\"http:\\/\\/pbs.twimg.com\\/profile_images\\/580189141347921920\\/rmGHHxpD_normal.jpg\",\"profile_image_url_https\":\"https:\\/\\/pbs.twimg.com\\/profile_images\\/580189141347921920\\/rmGHHxpD_normal.jpg\",\"profile_banner_url\":\"https:\\/\\/pbs.twimg.com\\/profile_banners\\/71128740\\/1401841557\",\"default_profile\":false,\"default_profile_image\":false,\"following\":null,\"follow_request_sent\":null,\"notifications\":null},\"geo\":null,\"coordinates\":null,\"place\":null,\"contributors\":null,\"retweet_count\":0,\"favorite_count\":0,\"entities\":{\"hashtags\":[{\"text\":\"tourism\",\"indices\":[74,82]},{\"text\":\"travelnews\",\"indices\":[83,94]}],\"trends\":[],\"urls\":[{\"url\":\"http:\\/\\/t.co\\/4WAWxmNBCd\",\"expanded_url\":\"http:\\/\\/buff.ly\\/1EJe7dY\",\"display_url\":\"buff.ly\\/1EJe7dY\",\"indices\":[51,73]}],\"user_mentions\":[],\"symbols\":[]},\"favorited\":false,\"retweeted\":false,\"possibly_sensitive\":false,\"filter_level\":\"low\",\"lang\":\"en\",\"timestamp_ms\":\"1431665170666\"}")

      expect(hashtag_data.top_ten).to eq("[{\"hashtag\":\"travelnews\",\"count\":1},{\"hashtag\":\"tourism\",\"count\":1}]")
    end
  end
end
