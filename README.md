resque_redis_composite
======================

This gems allows Resque to handle queues located on seperate Redis servers.

Requirements
------------

Currently working with Resque 1.23.x and 1.24.x
I haven't looked into Resque 2 yet, but it might be possible to natively handle multiple Redis instances with the new `Resque::Backend` class.

Usage
-----

    config = {
      "default" => "localhost:6379",
      "some_other_queue" => "otherbox:6379"
    }

    Resque.redis = Resque::RedisComposite.create(config)

Alternatively, `config` can be one of :

  * a single connection string, it will become the default connection:

    `config = "localhost:6379"`

  * a hash with any combination of server values supported by Resque:
    * a Redis connection url : `redis://...`
    * a Redis client : `Redis.new(:host => ..., :port => ...)`
    * a Redis namespace : `Redis::Namespace(..., :redis => ...)`

Notes
-----

Resque Stats will always be stored on the `default` Redis server.

