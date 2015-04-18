#!/usr/bin/ruby

require 'open-uri'
require 'ostruct'
require 'json'

class Main
	def self.run
		pause_time = 5
		
		while(true) do
			puts "Updating sequence...\n"
			data = OpenStruct.new(JSON.load(open('http://likebox.es/animations/1.json')))
			puts "Setting sequence to: #{data.file}\n"
			
			open('img/current_sequence.gif', 'wb') do |file|
			  file << open(data.file).read
			end
			
			puts "Killing previous instance..."
			`pkill -f current_sequence.gif`
			
			puts "Launching led-image-viewer...\n";	
			`./led-image-viewer -r16 img/current_sequence.gif`
			puts "Waiting... #{pause_time} seconds\n";
			
			sleep pause_time
		end
	end
end

Main.run