require 'pp'

class Racer
	# Attributes that allow to set/get each of the following properties:
	# id, number, first_name, last_name, gender, group and secs
	attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs

	def to_s
    	"#{@id}: #{@number}, #{@first_name} #{@last_name}, #{@gender}, #{@group}, #{@secs}"
  	end

  	# initialize from both a Mongo and Web hash
  	# Initializer that can set the properties of the class using the keys from a racers document. 
  	# It must:
  	# - Accept a hash of properties
	# - Assign instance attributes to the values from the hash
	# - For the id property, it tests whether the hash is coming from a web page [:id] 
	# or from a MongoDB query [:_id] and assign the value to whichever is non-nil.
	def initialize(params={})
	    #switch between both internal and external views of id and population
	    @id=params[:_id].nil? ? params[:id] : params[:_id].to_s
		@number=params[:number].to_i
		@first_name=params[:first_name]
		@last_name=params[:last_name]
		@gender=params[:gender]
		@group=params[:group]
		@secs=params[:secs].to_i
	end

	#convinience method for access to client in console
	def self.mongo_client
		Mongoid::Clients.default
	end

	#convinience method for access to racer collection
	def self.collection
		self.mongo_client['racers']
	end

	# Class method all. This method must:
	# - Accept an optional prototype, optional sort, optional skip, and optional limit. 
	# 		The default for the prototype is to “match all” – which means you must provide it 
	# 		a document that matches all records. 
	# 		The default for sort must be by number ascending. 
	# 		The default for skip must be 0 
	# 		The default for limit must be nil.
	# - Find all racers that match the given prototype
	# - Sort them by the given hash criteria
	# - Skip the specified number of documents
	# - Limit the number of documents returned if limit is specified
	# - Return the result	
	def self.all(prototype={}, sort={:number=>1}, skip=0, limit=nil)
		result=collection.find(prototype)
			.sort(sort)
			.skip(skip)
    	result=result.limit(limit) if !limit.nil?
	    return result	
	end

	# Class method find. This method must:
	# - Accept a single id parameter that is either a string or BSON::ObjectId 
	# Note: it must be able to handle either format.
	# -Find the specific document with that _id
	# -Return the racer document represented by that id
	def self.find id
		result=collection.find(:_id => BSON::ObjectId.from_string(id)).first
		return result.nil? ? nil : Racer.new(result)
	end

	# Instance method save. 
	# Creates a new document using the current instance.
	# This method must:
	# - Take no arguments
	# - Insert the current state of the Racer instance into the database
	# - Obtain the inserted document _id from the result and assign the 
	# to_s value of the _id to the instance attribute @id	
	def save
		result=self.class.collection
			.insert_one(number:@number, first_name:@first_name, last_name:@last_name, gender:@gender, group:@group, secs:@secs)
		@id=result.inserted_id.to_s	
	end

	# Instance method update. This method must:
	# - Accept a hash as an input parameter
	# - Updates the state of the instance variables – except for @id. That never should change.
	# - Find the racer associated with the current @id instance variable in the database
	# - Update the racer with the supplied values – replacing all values
	def update(params)
		@number=params[:number].to_i
		@first_name=params[:first_name]
		@last_name=params[:last_name]
		@gender=params[:gender]
		@group=params[:group]
		@secs=params[:secs].to_i

		params.slice!(:number, :first_name, :last_name, :gender, :group, :secs)
		self.class.collection
			.find(:_id=>BSON::ObjectId.from_string(@id))
			.replace_one(params)
	end

end