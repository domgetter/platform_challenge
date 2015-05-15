require_relative "./spec_helper"
require_relative "../models/hashtag_data"

RSpec.describe HashtagData do
  describe "#add_hashtag" do
    it "works successfully" do
      hashtag_data = HashtagData.new
      hashtag_data.add_hashtag("test123")
      hashtag_data.add_hashtag("test123")
      hashtag_data.add_hashtag("test456")

      expect(hashtag_data.top_ten).to eq("[{\"hashtag\":\"test123\",\"count\":2},{\"hashtag\":\"test456\",\"count\":1}]")
    end
  end

  describe "#reset" do
    it "works successfully" do
      hashtag_data = HashtagData.new
      hashtag_data.add_hashtag("test123")
      hashtag_data.add_hashtag("test123")
      hashtag_data.reset

      expect(hashtag_data.top_ten).to eq("[]")
    end
  end

  describe "#topten" do
    it "works successfully" do
      hashtag_data = HashtagData.new
      hashtag_data.add_hashtag("test123")
      hashtag_data.add_hashtag("test123")
      hashtag_data.add_hashtag("test456")

      expect(hashtag_data.top_ten).to eq("[{\"hashtag\":\"test123\",\"count\":2},{\"hashtag\":\"test456\",\"count\":1}]")
    end
  end
end
