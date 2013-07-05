require 'resque'
require 'resque/redis_composite'
require 'active_support/concern'
require 'active_support/core_ext/module/aliasing'

module ResqueRedisComposite
  extend ActiveSupport::Concern

  included do
    alias_method_chain :redis=, :composite
  end

  def redis_with_composite=(server)
    if Resque::RedisComposite == server
      @redis = server
    else
      redis_without_composite = server
    end
  end

end

Resque.send(:include, ResqueRedisComposite)
