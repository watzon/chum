require "../src/chum"
require "./human_resources/**"

Log.setup(:debug)

engine = Chum::Engine.new

engine.start_spider(HumanResources::Spider.new)
engine.wait
