# encoding: utf-8
require "json"

class HashtagData
  def initialize
    # create 6 hashes representing 10 second chunks of time
    # this allows for a rotating set of hashes to represent the last 60 seconds
    # of hashtags
    @hashtags = 6.times.map { Hash.new(0) }
    @mutex = Mutex.new
    @current_hashtag_index = nil
  end

  def add_hashtag(hashtag, now = Time.now)
    determine_hashtag_index(now)
    @mutex.synchronize do
      @hashtags[@current_hashtag_index][hashtag.downcase] += 1
    end
  end

  def reset
    $logger.info("reset hashtags")

    @mutex.synchronize do
      @hashtags.each { |h| h.clear }
      @current_hashtag_index = nil
    end
  end

  def top_ten
    data = []
    all_hash = Hash.new(0)
    @mutex.synchronize do
      @hashtags.each do |hashtag|
        hashtag.each do |key, value|
          all_hash[key] += value
        end
      end
      data = all_hash.sort_by {|key, value| value }.reverse[0..9]
    end

    data.map { |d| { hashtag: d[0], count: d[1] } }.to_json
  end

  def debug
    data = []
    @mutex.synchronize do
      @hashtags.each_with_index do |hashtag, index|
        data << { index => hashtag }
      end
    end
    data.to_json
  end

  private

  def determine_hashtag_index(now = Time.now)
    new_index = now.to_i % 60 / 10
    @mutex.synchronize do
      if @current_hashtag_index != new_index
        # there is a problem if we skip a time because we get no data for 10 seconds
        # that hashtag won't get cleared
        @hashtags[new_index].clear
        @current_hashtag_index = new_index
      end
    end
  end
end
