class Racer
	#convinience method for access to client in console
	def self.mongo_client
		Mongoid::Clients.default
	end

	#convinience method for access to racer collection
	def self.collection
		self.mongo_client['racers']
	end
end