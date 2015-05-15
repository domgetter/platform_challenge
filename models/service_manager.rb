# encoding: utf-8
require "thwait"

class ServiceManager
  def initialize(hashtag_data)
    @threads = []
    @hup = 0
    @hashtag_data = hashtag_data
  end

  def add_thread(thread)
    @threads << thread
  end

  def quit_on_int
    Thread.new {
      $logger.info("Quitting on interupt signal.")
    }.join
    exit
  end

  def quit_on_quit
    Thread.new {
      $logger.info("Quitting on quit signal.")
      @threads.each { |t| t[:quit] = true }
    }.join

    exit
  end

  def handle_hup
    # need to run reset inside a thread because hashtag data reset uses
    # mutex.synchronize which can't be called from a trap condition
    Thread.new {
      @hup += 1
      $logger.info("HUP! (count: #{@hup})")

      @threads.each { |t| t[:hup] = true }
      @hashtag_data.reset
    }.join
  end

  def start
    trap("INT") { quit_on_int }
    trap("HUP") { handle_hup }
    trap("QUIT") { quit_on_quit }

    @threads.map(&:join)
  end
end
