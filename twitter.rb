require 'Twitter'
currentTime = Time.now

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ""
  config.consumer_secret     = ""
  config.access_token        = "-"
  config.access_token_secret = ""
end

print "Type the user's twitter screen name you want to read: "
user_name_info = $stdin.gets.chomp

filename = user_name_info + (".csv")
targetFileToWrite = open(filename, 'w')
targetFileToWrite.truncate(0)


def collect_with_max_id(collection=[], max_id=nil, &block)
  response = yield(max_id)
  collection += response
  response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
end

def client.get_all_tweets(user)
  collect_with_max_id do |max_id|
    options = {count: 200, include_rts: true}
    options[:max_id] = max_id unless max_id.nil?
    user_timeline(user, options)
  end
end
results = client.user_timeline(user_name_info, {:exclude_replies => true, :include_rts => false})
results.each do |tweet|
  if tweet.created_at.strftime("%y-%m-%d") == currentTime.strftime("%y-%m-%d")
    answer = []
    answer.push(tweet.user.name)
    answer.push(tweet.text.gsub(/,/, ""))
    answer.push(tweet.id)
    answer.push(tweet.created_at.strftime("%m-%d-%Y"))
    finalAnswer = answer.join(",")
    targetFileToWrite.write(finalAnswer)
    targetFileToWrite.write("\n")
  end
end

targetFileToWrite.close()

puts "All Tweets Recorded"
