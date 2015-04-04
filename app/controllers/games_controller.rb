class GamesController < ApplicationController
	before_filter :has_query,
	:only => [:search]
	def search
		@search = GamesSearch.new(query: params[:q])
		results = @search.search.only(:id)
		@games = results.paginate(:page => params[:page]).load(edition: {scope: Edition.includes(:work)})
		@qty = @games.count
		if @games.count == 1
			redirect_to @games.to_a[0]
		end
	end

	def index
		@search = GamesSearch.new()
		results = @search.all.only(:id)
		@games = results.paginate(:page => params[:page]).load(edition: {scope: Edition.includes(:work)})
	end

	private

	def has_query
		if params[:q].present?
			true
		else
			redirect_to :back, :alert => "You have to type a query string"
		end

		rescue ActionController::RedirectBackError
			redirect_to games_path, :alert => "You have to type a query string"
	end
end
