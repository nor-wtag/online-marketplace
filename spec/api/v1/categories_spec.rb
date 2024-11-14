require 'rails_helper'

RSpec.describe 'Categories API', type: :request do
  let!(:categories) { create_list(:category, 5) }
  let(:category_id) { categories.first.id }

  describe 'GET /api/v1/categories' do
    it 'returns all categories' do
      get '/api/v1/categories'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(5)
    end
  end

  describe 'GET /api/v1/categories/:id' do
    context 'when category exists' do
      it 'returns the category' do
        get "/api/v1/categories/#{category_id}"
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['id']).to eq(category_id)
      end
    end

    context 'when category does not exist' do
      it 'returns a 404 error' do
        get "/api/v1/categories/0"
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Category not found')
      end
    end
  end

  describe 'POST /api/v1/categories' do
    let(:valid_attributes) { { name: 'New Category', description: 'This is a new category' } }

    context 'when request is valid' do
      it 'creates a category' do
        post '/api/v1/categories', params: valid_attributes
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['name']).to eq('New Category')
      end
    end

    context 'when request is invalid' do
      it 'returns a 422 error' do
        post '/api/v1/categories', params: { name: nil }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to include("Name can't be blank")
      end
    end
  end

  describe 'PUT /api/v1/categories/:id' do
    let(:valid_attributes) { { name: 'Updated Name' } }

    context 'when category exists' do
      it 'updates the category' do
        put "/api/v1/categories/#{category_id}", params: valid_attributes
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['name']).to eq('Updated Name')
      end
    end

    context 'when category does not exist' do
      it 'returns a 404 error' do
        put '/api/v1/categories/0', params: valid_attributes
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Category not found')
      end
    end
  end

  describe 'DELETE /api/v1/categories/:id' do
    context 'when category exists' do
      it 'deletes the category' do
        expect {
          delete "/api/v1/categories/#{category_id}"
        }.to change { Category.count }.by(-1)
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Category deleted successfully')
      end
    end

    context 'when category does not exist' do
      it 'returns a 404 error' do
        delete '/api/v1/categories/0'
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Category not found')
      end
    end
  end
end
