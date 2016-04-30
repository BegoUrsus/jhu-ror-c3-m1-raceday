require 'pp'

class Racer
	#convinience method for access to client in console
	def self.mongo_client
		Mongoid::Clients.default
	end

	#convinience method for access to racer collection
	def self.collection
		self.mongo_client['racers']
	end


	def self.all(prototype={}, sort={:number=>1}, skip=0, limit=nil)
		result=collection.find(prototype)
			.sort(sort)
			.skip(skip)
    	result=result.limit(limit) if !limit.nil?
	    return result	
	end
end