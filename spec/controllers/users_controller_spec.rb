require 'rails_helper'

RSpec.describe UsersController, type: :controller do
 
  let(:user) { create(:user) }
  let(:invalid_user) { build(:invalid_user) }

  describe 'GET #index for showing the user interface' do
    it 'assigns a new user instance' do
      get :index
      expect(assigns(:user)).to be_a_new(User)
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show - Viewing a specific user' do
    it 'assigns the requested user as @user' do
      get :show, params: { id: user.id }
      expect(assigns(:user)).to eq(user)
      expect(response).to render_template(:show)
    end

    it 'redirects to index if the user is not found' do
      get :show, params: { id: 'nonexistent' }
      expect(response).to redirect_to(users_path)
      expect(flash[:alert]).to eq('User not found')
    end
  end

  describe 'GET #new for initializing a new user' do
    it 'creates a new User instance' do
      get :new
      expect(assigns(:user)).to be_a_new(User)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create for creating a new user' do
    context 'when provided valid user attributes' do
      it 'successfully creates a new user and redirects to the sign-in page' do
        expect {
          post :create, params: { user: attributes_for(:user) }
        }.to change(User, :count).by(1)

        expect(response).to redirect_to(sign_in_users_path)
        expect(flash[:notice]).to eq('User created successfully! Please sign in.')
      end
    end

    context 'when provided invalid user attributes' do
      it 'does not create a user, re-renders new, and displays an error' do
        expect {
          post :create, params: { user: attributes_for(:invalid_user) }
        }.not_to change(User, :count)

        expect(response).to render_template(:new)
        expect(flash[:alert]).not_to be_nil
      end
    end
  end

  describe 'POST #create_session for user login' do
    context 'with valid login credentials' do
      let!(:user) { create(:user, password: 'password') }
      it 'creates a session and redirects to the products page' do
        post :create_session, params: { email: user.email, password: 'password' }
        expect(session[:user_id]).to eq(user.id)
        expect(response).to redirect_to(products_path)
        expect(flash[:notice]).to eq('Successfully signed in!')
      end
    end

    context 'with invalid login credentials' do
      it 'does not create a session and re-renders the sign-in view' do
        post :create_session, params: { email: user.email, password: 'wrongpassword' }
        expect(session[:user_id]).to be_nil
        expect(response).to render_template(:sign_in)
        expect(flash[:alert]).to eq('Invalid email or password')
      end
    end
  end

  describe 'DELETE #destroy_session for user logout' do
    it 'clears the session and redirects to the sign-in page with a notice' do
      session[:user_id] = user.id
      delete :destroy_session
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(sign_in_users_path)
      expect(flash[:notice]).to eq('Successfully signed out!')
    end
  end

  describe 'PUT #update for modifying user details' do
    before { session[:user_id] = user.id }
    context 'when provided valid update attributes' do
      let(:new_attributes) { { username: 'updateduser', email: 'updated@example.com' } }

      it 'updates the user attributes and redirects to the products page with a success message' do
        put :update, params: { id: user.to_param, user: { username: 'updateduser', email: 'updated@example.com' } }
        user.reload
        expect(user.username).to eq('updateduser')
        expect(response).to redirect_to(products_path)
        expect(flash[:notice]).to eq('User updated successfully!')
      end
    end

    context 'when provided invalid update attributes' do
      it 'does not update the user, re-renders the edit view, and shows errors' do
        put :update, params: { id: user.to_param, user: { username: '', email: 'invalid-email' } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy for deleting a user account' do
    before { session[:user_id] = user.id }
    it 'removes the user from the database and redirects to the users list with a notice' do
      delete :destroy, params: { id: user.to_param }
      expect(User.exists?(user.id)).to be_falsey
      expect(response).to redirect_to(users_path)
      expect(flash[:notice]).to eq('User deleted successfully.')
    end
  end
end
