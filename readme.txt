Platform Challenge
Details

Create a service in Ruby that continuously consumes the Twitter sample stream (https://dev.twitter.com/streaming/reference/get/statuses/sample), extracts any #hashtags from the text field and returns the top 10 hashtags from the past 60 seconds via an api endpoint.

The main objective is to demonstrate building a service that properly responds to signals, and concurrently reads and processes a stream of data.

Don't use any gems that aid in building the service or in concurrent processing (we want to see you using the stdlib for this)
You can use a testing gem such as rspec if you like, but minitest from the stdlib is fine too.
Don't use any gems for interacting with the Twitter API. Stick to net/http (or anything from the stdlib).
Use the oauth gem to sign requests.
Use the webrick library as your embedded web server.
The API endpoint should be /top10 and return JSON.
Your service should respond to standard unix signals in the following way:
HUP: Close and reopen the Twitter stream, reset all statistics to zero.
INT/TERM: Quick shutdown. Exit immediately.
QUIT: Graceful shutdown. Properly close stream and then exit.
Ensure your code has adequate test coverage. There should be both unit tests and integration tests.
Assume this will be deployed on a production system -- use best practices for credentials.
Do use bundler and rake.
Ensure that your service does not drop any tweets once you’ve started parsing the stream.

Tip: we don't want you to get caught up with OAuth fever, so here's a helper method for signing requests with the oauth gem:

require 'oauth'
def sign_request(req, params)
  consumer = OAuth::Consumer.new(params.fetch(:consumer_key), params.fetch(:consumer_secret),
                                 { :site => "https://stream.twitter.com", :scheme => :header })

  # now create the access token object from passed values
  token_hash = { :oauth_token => params.fetch(:access_token),
                 :oauth_token_secret => params.fetch(:access_token_secret) }
  access_token = OAuth::AccessToken.from_hash(consumer, token_hash)

  access_token.sign!(req)
end
Submission

Please create a github repo and provide us with the url. If you’d prefer to keep the repo private so others can’t see, let us know and we’ll send you the github users to add as collaborators. Commit early, commit often, and don't rebase -- we'd like to be able to see the commit history.


