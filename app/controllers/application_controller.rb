require 'uri'

class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

	before_filter :ignore_referral_spam, :fill_platforms

	def ignore_referral_spam
		if(request.referrer)
			@uri = URI(request.referrer)
			if(@uri.host)
				host = @uri.host.gsub(/^(www\.)?(.*)$/i, '\2')
				if(REFERRAL_SPAMMERS.include?(host))
					logger.info "[ignore_referral_spam] referral spammer detected: #{@uri.host}. 400 handed out."
					render :nothing => true, :status => 400
				end
			end
		end
	end

	def after_sign_in_path_for(resource)
		user_game_shelves_path(resource)
	end

	def fill_platforms
		@platforms = [ ["All", ""] ]
		@platform_hash = { "" => "All", nil => "All" }
		Platform.joins(:edition).group("platforms.id").having("count(editions.id) > ?", 0).order(:priority, :id).each do |p|
			@platforms << [p.display_title, p.id]
			@platform_hash[p.id.to_s] = p.display_title
		end
	end
end
