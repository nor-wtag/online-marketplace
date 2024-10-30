require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:valid_attributes) do
    {
      username: 'testuser',
      email: 'test@example.com',
      phone: '1234567890',
      password: 'password',
      role: 'buyer'
    }
  end

  let(:invalid_attributes) do
    {
      username: '',
      email: 'invalid-email',
      phone: 'not_a_number',
      password: 'short',
      role: ''
    }
  end

  describe 'GET #index' do
    it 'assigns a new user and loads all users' do
      user = User.create! valid_attributes
      get :index
      expect(assigns(:user)).to be_a_new(User)
      expect(assigns(:users)).to include(user)
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested user as @user' do
      user = User.create! valid_attributes
      get :show, params: { id: user.to_param }
      expect(assigns(:user)).to eq(user)
      expect(response).to render_template(:show)
    end

    it 'redirects to index if the user is not found' do
      get :show, params: { id: 'nonexistent' }
      expect(response).to redirect_to(users_path)
      expect(flash[:alert]).to eq('User not found')
    end
  end

  describe 'GET #new' do
    it 'assigns a new user as @user' do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new User and redirects to sign in' do
        expect {
          post :create, params: { user: valid_attributes }
        }.to change(User, :count).by(1)

        expect(response).to redirect_to(sign_in_users_path)
        expect(flash[:notice]).to eq('User created successfully! Please sign in.')
      end
    end

    context 'with invalid params' do
      it 'does not create a new User and re-renders new' do
        expect {
          post :create, params: { user: invalid_attributes }
        }.to change(User, :count).by(0)

        expect(response).to render_template(:new)
        expect(flash[:alert]).not_to be_nil
      end
    end
  end

  describe 'POST #create_session' do
    let!(:user) { User.create!(valid_attributes) }

    it 'creates a session and redirects to products path on valid login' do
      post :create_session, params: { email: user.email, password: valid_attributes[:password] }
      expect(session[:user_id]).to eq(user.id)
      expect(response).to redirect_to(products_path)
      expect(flash[:notice]).to eq('Successfully signed in!')
    end

    it 'does not create a session on invalid login and re-renders sign_in' do
      post :create_session, params: { email: user.email, password: 'wrongpassword' }
      expect(session[:user_id]).to be_nil
      expect(response).to render_template(:sign_in)
      expect(flash[:alert]).to eq('Invalid email or password')
    end
  end

  describe 'DELETE #destroy_session' do
    let!(:user) { User.create!(valid_attributes) }

    it 'destroys the session and redirects to sign-in page' do
      post :create_session, params: { email: user.email, password: valid_attributes[:password] }
      delete :destroy_session
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(sign_in_users_path)
      expect(flash[:notice]).to eq('Successfully signed out!')
    end
  end

  describe 'PUT #update' do
    let!(:user) { User.create!(valid_attributes) }

    context 'with valid params' do
      let(:new_attributes) do
        { username: 'updateduser', email: 'updated@example.com' }
      end

      it 'updates the requested user and redirects to products path' do
        put :update, params: { id: user.to_param, user: new_attributes }
        user.reload
        expect(user.username).to eq('updateduser')
        expect(user.email).to eq('updated@example.com')
        expect(response).to redirect_to(products_path)
        expect(flash[:notice]).to eq('User updated successfully!')
      end
    end

    context 'with invalid params' do
      it 'does not update the user and re-renders edit' do
        put :update, params: { id: user.to_param, user: invalid_attributes }
        user.reload
        expect(user.username).not_to eq(invalid_attributes[:username])
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:user) { User.create!(valid_attributes) }

    it 'deletes the user and redirects to users path' do
      expect {
        delete :destroy, params: { id: user.to_param }
      }.to change(User, :count).by(-1)
      expect(response).to redirect_to(users_path)
      expect(flash[:notice]).to eq('User deleted successfully.')
    end
  end
end
