#!/bin/ruby

require 'open-uri'
require 'ostruct'
require 'json'

class Main
	def self.run
		while(true) do
			data = OpenStruct.new(JSON.load(open('http://localhost.local/animations/1.json')))
			puts "Setting sequence to: #{data.file}"
			
			open('img/current_sequence.gif', 'wb') do |file|
			  file << open(data.file).read
			end
			
			sleep 10
		end
	end
end

Main.run