# require 'rails_helper'

# RSpec.describe UsersController, type: :controller do
#   let(:valid_attributes) {
#     {
#       username: 'testuser',
#       email: 'test@example.com',
#       password: 'password123',
#       phone: '1234567890',
#       role: 'buyer'
#     }
#   }

#   let(:invalid_attributes) {
#     {
#       username: '',
#       email: 'invalid_email',
#       password: 'short',
#       phone: 'abc123',
#       role: 'invalid_role'
#     }
#   }

#   describe "GET #index" do
#     it "returns a success response" do
#       get :index
#       expect(response).to be_successful
#     end
#   end

#   describe "GET #new" do
#     it "returns a success response" do
#       get :new
#       expect(response).to be_successful
#     end
#   end

#   describe "POST #create" do
#     context "with valid params" do
#       it "creates a new User" do
#         expect {
#           post :create, params: { user: valid_attributes }
#         }.to change(User, :count).by(1)
#       end

#       it "redirects to the sign_in page" do
#         post :create, params: { user: valid_attributes }
#         expect(response).to redirect_to(sign_in_users_path)
#         expect(flash[:notice]).to eq('User created successfully! Please sign in.')
#       end
#     end

#     context "with invalid params" do
#       it "does not create a new User" do
#         expect {
#           post :create, params: { user: invalid_attributes }
#         }.to change(User, :count).by(0)
#       end

#       it "renders the 'new' template with errors" do
#         post :create, params: { user: invalid_attributes }
#         expect(response).to render_template(:new)
#         expect(flash.now[:alert]).to include("Username can't be blank", "Email must be a valid email address", "Password is too short (minimum is 6 characters)", "Phone is not a number")
#       end
#     end
#   end

#   describe "GET #sign_in" do
#     it "returns a success response" do
#       get :sign_in
#       expect(response).to be_successful
#     end
#   end

#   describe "POST #create_session" do
#     before do
#       User.create!(valid_attributes)
#     end

#     context "with valid credentials" do
#       it "logs in the user" do
#         post :create_session, params: { email: 'test@example.com', password: 'password123' }
#         expect(session[:user_id]).to_not be_nil
#         expect(response).to redirect_to(products_path)
#         expect(flash[:notice]).to eq('Successfully signed in!')
#       end
#     end

#     context "with invalid credentials" do
#       it "does not log in the user" do
#         post :create_session, params: { email: 'test@example.com', password: 'wrongpassword' }
#         expect(session[:user_id]).to be_nil
#         expect(response).to render_template(:sign_in)
#         expect(flash.now[:alert]).to eq('Invalid email or password')
#       end
#     end
#   end

# describe "DELETE #destroy_session" do
#   it "logs out the user" do
#     delete :destroy_session
#     expect(session[:user_id]).to be_nil
#     expect(response).to redirect_to(root_path)
#     expect(flash[:notice]).to eq('Successfully signed out!')
#   end
# end

# describe "GET #products" do
#   context "when user is authenticated" do
#     before do
#       User.create!(valid_attributes)  # Create a valid user
#       post :create_session, params: { email: 'test@example.com', password: 'password123' }  # Log in the user
#     end

#     it "returns a success response" do
#       get :products
#       expect(response).to be_successful
#     end
#   end

#   context "when user is not authenticated" do
#     it "redirects to the sign-in page" do
#       get :products
#       expect(response).to redirect_to(sign_in_users_path)
#       expect(flash[:alert]).to eq('You need to sign in first.')
#     end
#   end
# end
# end
