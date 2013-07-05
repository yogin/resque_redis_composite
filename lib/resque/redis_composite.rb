module Resque
  class RedisComposite
    class MissingDefaultRedisInstance < StandardError; end

    DEFAULT_INSTANCE_NAME = 'default'

    attr_reader :queue_mapping

    def initialize(config)
      config = { DEFAULT_INSTANCE_NAME => config } if config.kind_of?(String)
      raise MissingDefaultRedisInstance, 'No default instance defined' unless config.key?(DEFAULT_INSTANCE_NAME)

      @queue_mapping = config.inject({}) do |hash, (queue_name, instance)|
        Resque.redis = instance
        hash[queue_name] = Resque.redis
        hash
      end
    end

    def method_missing(method_name, *args, &block)
      default_instance.send(method_name, *args, &block)
    end

    def client(queue = DEFAULT_INSTANCE_NAME)
      redis_instance_for(queue).client
    end

    # This is used to create a set of queue names, so needs some special treatment
    def sadd(key, value)
      if queues?(key)
        redis_instance_for(value).sadd(key, value)
      else
        redis_instance_for(key).sadd(key, value)
      end
    end

    # If we're using smembers to get queue names, we aggregate across all servers
    def smembers(key)
      if queues?(key)
        redis_instances.inject([]) { |a, s| a + s.smembers(key) }.uniq
      else
        redis_instance_for(key).smembers(key)
      end
    end

    # Sometimes we're pushing onto the 'failed' queue, and we want to make sure
    # the failures are pushed into the same Redis server as the queue is hosted on.
    def rpush(key, value)
      if failed?(key)
        queue_with_failure = Resque.decode(value)["queue"]
        redis_instance_for(queue_with_failure).rpush(key, value)
      else
        redis_instance_for(key).rpush(key, value)
      end
    end

    def lpop(key)
      redis_instance_for(key).lpop(key)
    end

    def namespace=(ignored)
      # this is here so that we don't get double-namespaced by Resque's initializer
    end

    protected

    def redis_instances # servers
      @queue_mapping.values
    end

    def default_instance # default_server
      @queue_mapping[DEFAULT_INSTANCE_NAME]
    end

    def redis_instance_for(queue) # server
      # queue_name = queue.to_s.sub(/^queue:/, "")
      # queue parsing : not match regular expression
      queue_name = queue.to_s.sub(/[\W\w]*queue:/,"")
      @queue_mapping[queue_name] || default_instance
    end

    def queues?(key)
      key.to_s == "queues"
    end

    def failed?(key)
      key.to_s == "failed"
    end

  end
end
