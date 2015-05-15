This rake test streams Twitters public status.
Runs a web server on port 8000 with an /top10 end point that returns the to ten hashtags for the last 60 seconds.
You must have the following environmental variables:
ENV["TWITTER_CONSUMER_KEY"]
ENV["TWITTER_CONSUMER_SECRET"]
ENV["TWITTER_ACCESS_TOKEN"]
ENV["TWITTER_ACCESS_TOKEN_SECRET"]

These come from setting up a twitter app:
https://apps.twitter.com/
You need to set up both Application Settings and Your Access Token

You can start the rake tast by just running rake. The default rake task will start up the webserver and the streaming of Twitter.

Thanks,
Dustin McCraw
