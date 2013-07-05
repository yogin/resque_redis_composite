require 'rubygems'
require 'rspec'
require 'resque'

$:.unshift "#{File.dirname(__FILE__)}/../lib"
require 'resque/redis_composite'

describe Resque::RedisComposite do
  describe "initialize" do

    it "accepts a redis client" do
      Resque.redis = Redis.new(:host => 'localhost', :port => 5380)
      Resque.redis.should be_a(Redis::Namespace)
      Resque.redis.client.port.should == 5380
    end

    it "accepts redis composite with a connection string" do
      Resque.redis = Resque::RedisComposite.new("localhost:5380")
      Resque.redis.client.port.should == 5380
    end
  
    it "accepts redis composite with a hash of connection strings" do
      Resque.redis = Resque::RedisComposite.new("default" => "localhost:5380", "test" => "localhost:5381")
      Resque.redis.client.port.should == 5380
      Resque.redis.client("test").port.should == 5381
    end
  
    it "raises exception Resque::RedisComposite::MissingDefaultRedisInstance if there are no default instance" do
      expect {
        Resque::RedisComposite.new("foo" => "localhost:5380", "bar" => "localhost:5381")
      }.to raise_error(Resque::RedisComposite::MissingDefaultRedisInstance)
    end    
  end
  
  describe "redis interface" do
#    before do
      #let(:default_instance) { mock("default") }
      #let(:special_instance) { mock("special") }
    #end

    #it "properly namespaces the resque queues" do
      #special_instance.should_receive(:sadd).with("resque:queues", "stuff")
      #special_instance.should_receive(:rpush).with("resque:queue:stuff", '{"class":"SomeClass","args":"do something"}')

      #Resque.redis = Resque::RedisComposite.new("default" => default_instance, "stuff" => special_instance)
      #Resque.push("stuff", :class => "SomeClass", :args => "do something")
    #end
    
    #it "delegates most calls to the default server" do
      #@default_server.should_receive(:srem)
      #@default_server.should_receive(:get)

      #redis = Resque::RedisComposite.new("default" => @default_server, "stuff" => @special_server)
      #redis.srem(:workers, self)
      #redis.get(:workers)
    #end

    #describe "Resque.push" do
      #it "pushes jobs onto the specific Redis server" do
        #@special_server.should_receive(:sadd)
        #@special_server.should_receive(:rpush)

        #Resque.redis = Resque::RedisComposite.new("default" => @default_server, "stuff" => @special_server)
        #Resque.push("stuff", :class => "SomeClass", :args => "do something")
      #end

      #it "pushes jobs onto the default Redis server" do
        #@default_server.should_receive(:sadd)
        #@default_server.should_receive(:rpush)

        #Resque.redis = Resque::RedisComposite.new("default" => @default_server, "stuff" => @special_server)
        #Resque.push("email", :class => "SomeOtherClass", :args => "do something else")
      #end
    #end

    #describe "Resque.pop" do
      #it "pops jobs off the specific Redis server" do
        #@special_server.should_receive(:lpop)

        #Resque.redis = Resque::RedisComposite.new("default" => @default_server, "stuff" => @special_server)
        #Resque.pop("stuff")
      #end

      #it "pops jobs off the default Redis server" do
        #@default_server.should_receive(:lpop)

        #Resque.redis = Resque::RedisComposite.new("default" => @default_server, "stuff" => @special_server)
        #Resque.pop("email")
      #end
    #end

    #describe "Resque.queues" do
      #it "aggregates all the queues" do
        #@default_server.should_receive(:smembers).with("resque:queues").and_return(%w(a b c d))
        #@special_server.should_receive(:smembers).with("resque:queues").and_return(%w(d e f))
      
        #Resque.redis = Resque::RedisComposite.new("default" => @default_server, "stuff" => @special_server)
        #Resque.queues.sort.should == %w(a b c d e f)
      #end
    #end
    
    #describe "Resque::Failure.create" do
      #it "pushes the failure onto the specific Redis server" do
        #@special_server.should_receive(:rpush)
      
        #Resque.redis = Resque::RedisComposite.new("default" => @default_server, "stuff" => @special_server)
        #Resque::Failure.create(:queue => "stuff", :exception => StandardError.new)
      #end

      #it "pushes the failure onto the default Redis server" do
        #@default_server.should_receive(:rpush)
      
        #Resque.redis = Resque::RedisComposite.new("default" => @default_server, "stuff" => @special_server)
        #Resque::Failure.create(:queue => "transactions", :exception => StandardError.new)
      #end
    #end
  end
end
