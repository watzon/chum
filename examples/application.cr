require "../src/chum"
require "./human_resources/**"

engine = Chum::Engine.new

engine.start_spider(HumanResources::Spider.new)
engine.wait
