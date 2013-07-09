Gem::Specification.new do |s|
  s.name        = "resque_redis_composite"
  s.description = "Allowing Resque to handle queues accross multiple Redis instances"
  s.version     = "1.0.2"
  s.authors     = [ "redsquirrel", "jiHyunBae", "Anthony Powles" ]
  s.summary     = "Resque support for multiple Redis instances"
  s.homepage    = "https://github.com/yogin/resque_redis_composite"
  s.files       = `git ls-files`.split($/)

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry"

  #s.add_dependency "activesupport", ">= 3.0.0"
  s.add_dependency "resque"
end
