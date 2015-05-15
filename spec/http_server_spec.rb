require_relative "./spec_helper"
require_relative "../models/http_server"

RSpec.describe HttpServer do
  describe "#start" do
    it "starts up" do
      webrick = instance_double("WEBrick::HTTPServer")
      hashtag_data = HashtagData.new

      allow(WEBrick::HTTPServer).to receive(:new) { webrick }
      expect(webrick).to receive(:mount_proc).exactly(3).times
      expect(webrick).to receive(:start)

      http_server = HttpServer.new(hashtag_data)
      http_server.start
    end
  end
end
