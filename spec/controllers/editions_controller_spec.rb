require 'spec_helper'
include Warden::Test::Helpers
Warden.test_mode!

describe EditionsController do
	before(:example) do
		@user = FactoryGirl.create(:user, :admin)
		sign_in :user, @user
	end
	after(:example) do
		Warden.test_reset!
	end

	describe "GET#new" do
		it "populates the @edition variable with a new edition" do
			# when
			get :new

			# then
			expect(assigns(:edition).attributes).to eq(Edition.new.attributes)
		end
		it "populates the @work variable with a new work" do
			# when
			get :new

			# then
			expect(assigns(:work).attributes).to eq(Work.new.attributes)
		end
		it "populates the @work variable with a existing work" do
			#given
			work = FactoryGirl.create(:work)

			# when
			get :new, work_id: work

			# then
			expect(assigns(:work)).to eq(work)
		end
		it "should render the new template" do
			# when
			get :new

			# then
			expect(response).to render_template :new
		end
		it "should render the new template with existing work" do
			#given
			work = FactoryGirl.create(:work)

			# when
			get :new, work_id: work

			# then
			expect(response).to render_template :new
		end
	end

	describe "PATCH #do_transform" do
		it "should create expansion, delete edition and work" do
			#given
			edition = FactoryGirl.create(:edition, description: "MY-OLD-EDITION-NOW-EXPANSION")
			parent_edition = FactoryGirl.create(:edition)
			work = edition.work

			expect{
				# when
				patch :do_transform, id: edition, parent_edition_id: parent_edition.id
			}.to change(Expansion,:count).by(1).and change(Work,:count).by(-1).and change(Edition,:count).by(-1)

			# then
			expect{ Work.friendly.find(work.id) }.to raise_exception(ActiveRecord::RecordNotFound)
			expect{ Edition.friendly.find(edition.id) }.to raise_exception(ActiveRecord::RecordNotFound)
			expect(parent_edition.expansions.last.description).to eq(edition.description)
		end

		it "should create expansion, delete edition but not work" do
			#given
			edition = FactoryGirl.create(:edition, description: "MY-OLD-EDITION-NOW-EXPANSION")
			another_edition = FactoryGirl.create(:edition, work: edition.work)
			parent_edition = FactoryGirl.create(:edition)
			work = edition.work

			expect{
				# when
				patch :do_transform, id: edition, parent_edition_id: parent_edition.id
			}.to change(Expansion,:count).by(1).and change(Work,:count).by(0).and change(Edition,:count).by(-1)

			# then
			expect{ Edition.friendly.find(edition.id) }.to raise_exception(ActiveRecord::RecordNotFound)
			expect(Work.friendly.find(work.id)).to eq(work)
			expect(parent_edition.expansions.last.description).to eq(edition.description)
		end
	end
end
