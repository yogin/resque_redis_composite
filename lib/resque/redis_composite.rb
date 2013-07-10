module Resque
  class RedisComposite
    class NoDefaultRedisServerError < StandardError; end

    DEFAULT_SERVER_NAME = 'default'

    attr_reader :mapping

    class << self

      def create(config)
        Redis::Namespace.new(nil, :redis => RedisComposite.new(config))
      end

      def reconnect_all(job = nil)
        return unless Resque.redis.redis.kind_of?(Resque::RedisComposite)
        Resque.redis.mapping.each { |_, server| server.redis.client.reconnect }
      end

    end

    def initialize(config)
      config = { DEFAULT_SERVER_NAME => config } unless config.kind_of?(Hash)

      config = HashWithIndifferentAccess.new(config)
      raise NoDefaultRedisServerError, "No default server defined in configuration : #{config.inspect}" unless config.key?(DEFAULT_SERVER_NAME)

      # quick backup for what's in Resque
      original_resque_server = Resque.redis

      @mapping = config.inject(HashWithIndifferentAccess.new) do |hash, (queue_name, server)|
        # leaving Resque create Redis::Namespace instances
        Resque.redis = server

        hash[queue_name] = Resque.redis
        hash
      end

      Resque.redis = original_resque_server
    end

    def method_missing(method_name, *args, &block)
      # most redis command's first parameter is the key, so it should work most of the time
      server_for(args.first).send(method_name, *args, &block)
    end

    def client(queue = DEFAULT_SERVER_NAME)
      # TODO properly handle Resque.redis_id, probably need to return all our client ids
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

    # This is used to completely delete a queue, so needs some special treatment
    def srem(key, value)
      if queues?(key)
        server_for(value).srem(key, value)
      else
        server_for(key).srem(key, value)
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

    protected

    def servers
      @mapping.values
    end

    def default_server
      @mapping[DEFAULT_SERVER_NAME]
    end

    def server_for(queue)
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
