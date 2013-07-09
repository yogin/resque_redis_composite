module Resque
  class RedisComposite
    class MissingDefaultRedisInstance < StandardError; end

    DEFAULT_SERVER_NAME = 'default'

    attr_reader :mapping

    def initialize(config)
      config = { DEFAULT_SERVER_NAME => config } unless config.kind_of?(Hash)
      config = HashWithIndifferentAccess.new(config)
      raise MissingDefaultRedisInstance, "No default server defined in configuration : #{config.inspect}" unless config.key?(DEFAULT_SERVER_NAME)

      @mapping = config.inject(HashWithIndifferentAccess.new) do |hash, (queue_name, instance)|
        # leaving Resque create Redis::Namespace instances
        Resque.redis = instance
        hash[queue_name] = Resque.redis
        hash
      end
    end

    def method_missing(method_name, *args, &block)
      default_server.send(method_name, *args, &block)
    end

    def client(queue = DEFAULT_SERVER_NAME)
      server_for(queue).client
    end

    # This is used to create a set of queue names, so needs some special treatment
    def sadd(key, value)
      if queues?(key)
        server_for(value).sadd(key, value)
      else
        server_for(key).sadd(key, value)
      end
    end

    # If we're using smembers to get queue names, we aggregate across all servers
    def smembers(key)
      if queues?(key)
        servers.inject([]) { |a, s| a + s.smembers(key) }.uniq
      else
        server_for(key).smembers(key)
      end
    end

    # Sometimes we're pushing onto the 'failed' queue, and we want to make sure
    # the failures are pushed into the same Redis server as the queue is hosted on.
    def rpush(key, value)
      if failed?(key)
        queue_with_failure = Resque.decode(value)["queue"]
        server_for(queue_with_failure).rpush(key, value)
      else
        server_for(key).rpush(key, value)
      end
    end

    def lpop(key)
      redis_server_for(key).lpop(key)
    end

    def namespace=(ignored)
      # this is here so that we don't get double-namespaced by Resque's initializer
    end

    protected

    def servers # servers
      @mapping.values
    end

    def default_server # default_server
      @mapping[DEFAULT_SERVER_NAME]
    end

    def server_for(queue) # server
      # queue_name = queue.to_s.sub(/^queue:/, "")
      # queue parsing : not match regular expression
      queue_name = queue.to_s.sub(/[\W\w]*queue:/,"")
      @mapping[queue_name] || default_server
    end

    def queues?(key)
      key.to_s == "queues"
    end

    def failed?(key)
      key.to_s == "failed"
    end

  end
end
