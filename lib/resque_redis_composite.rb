require 'resque/redis_composite'

module ResqueRedisComposite

  def included(base)
    base.class_eval do
      alias_method :original_redis=, :redis=
    end
  end

  def redis=(server)
    if Resque::RedisComposite == server
      @redis = server
    else
      Resque.original_redis = server
    end
  end

end

Resque.send(:include, ResqueRedisComposite)

