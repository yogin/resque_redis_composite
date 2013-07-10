require 'resque'
require 'resque/redis_composite'

# need to stick this in the application initializer, need to see how I can do it from the gem
# putting it here does not work
#Resque.after_fork do |job|
  #Resque.redis.mapping.each { |_,server| server.redis.client.reconnect } if Resque.redis.redis.kind_of?(Resque::RedisComposite)
#end

