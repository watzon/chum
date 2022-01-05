require "../src/chum"
require "./human_resources/**"

Log.builder.bind "*", :debug, Log::IOBackend.new

engine = Chum::Engine.new

engine.start_spider(HumanResources::Spider.new)
engine.wait
