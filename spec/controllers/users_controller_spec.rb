# require 'rails_helper'

# RSpec.describe UsersController, type: :controller do
#   let(:user) { create(:user) }

#   before do
#     sign_in user
#   end

#   describe 'GET #index' do
#     it 'renders the index page with all users' do
#       get :index
#       expect(response).to render_template(:index)
#       expect(assigns(:users)).to include(user)
#     end
#   end

#   describe 'GET #edit' do
#     it 'allows the current user to edit their profile' do
#       get :edit, params: { id: user.id }
#       expect(response).to render_template(:edit)
#       expect(assigns(:user)).to eq(user)
#     end
#   end
# end
