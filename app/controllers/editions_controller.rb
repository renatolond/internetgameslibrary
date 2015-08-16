require "github/markdown"

class EditionsController < ApplicationController
	before_filter :authenticate_user!,
	:only => [:new, :create, :edit, :update, :to_review, :review]

	before_filter :reviewer_only,
	:only => [:to_review, :review]

	before_filter :game_maker_only,
	:only => [:new, :create, :edit, :update, :transform, :do_transform]

	before_filter :parent_edition_exists,
	:only => [:do_transform]

	before_filter :edition_exists,
	:only => [:edit, :update, :show, :transform, :do_transform]

	before_filter :edition_visible,
	:only => [:show]

	def new
		@edition = Edition.new
		@work = Work.friendly.find(params[:work_id])
		rescue ActiveRecord::RecordNotFound
			@work = Work.new
	end
	def existing_work
		@work = Work.new(work_params)
		@existing_work = Work.friendly.find(params.require(:existing_work).permit(:id)[:id])
		respond_to do |format|
			  format.js
		end
	end

	def create
		@edition = Edition.new(edition_params)
		work_option = params.permit(:work_option)[:work_option]
		unless work_option == "existing"
			@work = Work.new(work_params)
			if @work.save!
				@edition.work_id = @work.id
				if @edition.save
					flash[:notice] = "Your edition was added!"
					redirect_to @edition
				else
					render 'new'
				end
			else
				render 'new'
			end
		else
			@work = Work.find_by_id(params.require(:existing_work).permit(:id)[:id])
			@edition.work_id = @work.id
			if @edition.save
				flash[:notice] = "Your edition was added!"
				redirect_to @edition
			else
				render 'new'
			end
		end
	end
	def index
		@editions = Edition.where(status: Edition.statuses[:active]).paginate(:page => params[:page]).order('title')
	end
	def edit
		@edition = Edition.friendly.find(params[:id])
		@work = @edition.work
	end
	def update
		@edition = Edition.friendly.find(params[:id])
		@work = @edition.work
		if @work.update_attributes(work_params)
			if @edition.update_attributes(edition_params)
				flash[:notice] = "Your changes were saved!"
				redirect_to @edition
			else
				render 'edit'
			end
		else
			render 'edit'
		end
	end
	def show
		@edition = Edition.friendly.find(params[:id])
		@other_editions_count = Edition.where("work_id = ? and status = ? and id <> ?",@edition.work.id,Edition.statuses[:active],@edition.id).count()
		@other_editions = Edition.where("work_id = ? and status = ? and id <> ?",@edition.work.id,Edition.statuses[:active],@edition.id).limit(5)
		@description = GitHub::Markdown.render_gfm(@edition.description.present? ? @edition.description : "").html_safe
		params[:platform] = @edition.platform_id.to_s
	end
	def to_review
		@editions = Edition.where(status: Edition.statuses[:unreviewed])
	end
	def review
		review_option = params.permit(:review_option)[:review_option]
		unless (review_option == "delete" or review_option == "accept")
			redirect_to :back, :alert => "Unknown option"
		else
			edition_id = params.require(:edition).permit(:id)[:id]
			edition = Edition.friendly.find(edition_id)
			if review_option == "delete"
				edition.status = Edition.statuses[:deleted]
			end
			if review_option == "accept"
				edition.status = Edition.statuses[:active]
			end
			edition.save!

			redirect_to to_review_editions_path
		end
		rescue ActionController::RedirectBackError
			redirect_to '/', :alert => "Unknown option"
	end
	def transform
		@edition = Edition.friendly.find(params[:id])
		params[:platform] = @edition.platform_id.to_s
	end
	def do_transform
		@edition = Edition.friendly.find(params[:id])
		@parent_edition = Edition.friendly.find(params[:parent_edition_id])

		transformed_expansion = Expansion.new()
		transformed_expansion.copy_from_edition(@edition)
		transformed_expansion.edition = @parent_edition
		transformed_expansion.save!

		old_work = @edition.work
		@edition.destroy
		if old_work.editions.length == 0
			old_work.destroy
		end

		redirect_to [transformed_expansion.edition, transformed_expansion]
	end

	private
	def edition_params
		params.require(:edition).permit(:title,:developer,:publisher,:description,:release_date,:platform_id,:region_id, :coverart, :media_id, :delete_coverart)
	end
	def work_params
		params.require(:work).permit(:original_title, :original_release_date)
	end

	def parent_edition_exists
		_edition_exists(params[:parent_edition_id])
	end

	def edition_exists
		_edition_exists(params[:id])
	end

	def edition_visible
		edition = Edition.friendly.find(params[:id])
		if edition.status != Edition.statuses[:active] and not (current_user and (current_user.admin? || current_user.reviewer?))
			redirect_to :back, :alert => "Game not found"
			return false
		else
			return true
		end

		rescue ActionController::RedirectBackError
			redirect_to '/', :alert => "Game not found"
	end
end
