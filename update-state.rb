#!/usr/bin/ruby

require 'open-uri'
require 'logger'
require 'ostruct'
require 'json'

class Main  
  def self.set_image(filename)
    full_path = "img/#{filename}"
    if !File.exists?(full_path)
      logger.warn("Aborting set_image because target file doesn't exist")
    end
      
    old_pid = `pidof led-image-viewer`

    unless old_pid.strip == ""
      # sleep 0.05 # Allow some time for the new instance to load the image (TODO: Scan for pids instead!)
      logger.info "Killing previous instance..."
      `kill -s9 #{old_pid}`
    end
    
    # logger.info "Launching led-image-viewer...";
    `nice -19 ./led-image-viewer -r16 #{full_path} -d &`
  end
  
  def self.default_filename
    'current_sequence.gif'
  end
  
  def self.loading_filename
    'loading.gif'
  end
  
  def self.logger
    @@logger ||= Logger.new('likebox.log')
  end
    
	def self.run
		server_update_sleep_time = 5
		display_update_sleep_time = 0.1
		quitting = false
    
    image_updated_at = Time.now - 3600
    screen_updated_at = Time.now

    `sudo pkill -f led-image-viewer`    
        
    set_image(loading_filename)
    
		Thread.new do
			while(!quitting) do
        begin
  				logger.info "Updating sequence..."
  				data = OpenStruct.new(JSON.load(open('http://likebox.es/likeboxes/1/?tick=true&format=json')))
  				logger.info "Got: #{data.inspect}"
  				logger.info "Setting sequence to: #{data.animation['file']}"

  				open('img/current_sequence.gif', 'wb') do |file|
  					file << open(data.animation['file'] + "?#{rand().to_s}").read
            image_updated_at = Time.now            
  				end

  				logger.info "Waiting... #{server_update_sleep_time} seconds before next SERVER update"
          
          sleep server_update_sleep_time
        rescue
          logger.error($!)
          sleep 1
        end
			end
		end

		Thread.new do            
			while(!quitting) do
        while image_updated_at < screen_updated_at
          logger.info "Waiting... #{display_update_sleep_time} seconds before next DISPLAY update"
          sleep 0.5
        end
          
        begin    
          screen_updated_at = Time.now
  				set_image(default_filename)
        rescue
          logger.error($!)
        end
                 
        sleep display_update_sleep_time
			end
		end

		# Endless wait-loop
		while(true) do
			sleep 1
		end

		quitting = true
	end
end

Main.run
