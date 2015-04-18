#!/usr/bin/ruby

require 'open-uri'
require 'ostruct'
require 'json'

class Main
	def self.run
		while(true) do
			data = OpenStruct.new(JSON.load(open('http://likebox.es/animations/1.json')))
			puts "Setting sequence to: #{data.file}"
			
			open('img/current_sequence.gif', 'wb') do |file|
			  file << open(data.file).read
			end
			
			`./led-image-viewer -r16 img/current_sequence.gif`
			
			sleep 10
		end
	end
end

Main.run