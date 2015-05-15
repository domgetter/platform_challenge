require "awesome_print"
require_relative "../stream_twitter"
require_relative "../hashtag_data"

RSpec.describe StreamTwitter do
  context "#json_parse" do
    # it "parses" do
    #   hashtag_data = instance_double("HashtagData")
    #   stream_twitter = StreamTwitter.new(hashtag_data)

    #   # expect(hashtag_data).to receive(:add_hashtag)
    #   stream_twitter.json_parse("test")
    # end
  end

  context "#parse_chunk" do
    describe "chunk has only one part" do
      it "ignores it if stream is nil" do
        hashtag_data = HashtagData.new
        stream_twitter = StreamTwitter.new(hashtag_data)
        stream_twitter.parse_chunk("123")
        expect(stream_twitter.current_tweet).to be_nil
      end
    end

    describe "chunk has two parts" do
      it "calls json_parse twice" do
        hashtag_data = HashtagData.new
        stream_twitter = StreamTwitter.new(hashtag_data)
        # "{\"123\":\"456\"}"
        expect(stream_twitter).to receive(:json_parse).with("{\"123\":\"456\"}").twice
        stream_twitter.parse_chunk("}\r\n{\"123\"")
        stream_twitter.parse_chunk(":\"456\"}\r\n{\"123\"")
        stream_twitter.parse_chunk(":\"456\"}\r\n{\"123\"")
      end
    end

    describe "chunk has multiple parts" do
      it "calls json_parse 4 times" do
        hashtag_data = HashtagData.new
        stream_twitter = StreamTwitter.new(hashtag_data)
        # "{\"123\":\"456\"}"
        expect(stream_twitter).to receive(:json_parse).with("{\"123\":\"456\"}").exactly(3).times
        stream_twitter.parse_chunk("}\r\n{\"123\":\"456\"}\r\n{\"123\":\"456\"}\r\n{\"123\":\"456\"}\r\n{\"123\"")
        # stream_twitter.parse_chunk(":\"456\"}\r\n{\"123\"")
      end
    end

    it "when chunk doesn't contain a full tweet" do
      hashtag_data = HashtagData.new
      stream_twitter = StreamTwitter.new(hashtag_data)
      stream_twitter.parse_chunk("123")

      # expect(hashtag_data).to receive(:add_hashtag)

    end

    it "when chunk contains the last part of a first tweet and the part of the next tweet" do
    end
  end
end
