require 'rails_helper'

RSpec.describe 'Products API', type: :request do
  let!(:products) { create_list(:product, 5) }
  let(:product_id) { products.first.id }

  describe 'GET /api/v1/products' do
    it 'returns all products' do
      get '/api/v1/products'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(5)
    end
  end

  describe 'GET /api/v1/products/:id' do
    context 'when product exists' do
      it 'returns the product' do
        get "/api/v1/products/#{product_id}"
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['id']).to eq(product_id)
      end
    end

    context 'when product does not exist' do
      it 'returns a 404 error' do
        get "/api/v1/products/0"
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Product not found')
      end
    end
  end

  describe 'POST /api/v1/products' do
    let(:valid_attributes) { { title: 'New Product', description: 'This is a new product', price: 10.5, stock: 100 } }

    context 'when request is valid' do
      it 'creates a product' do
        post '/api/v1/products', params: valid_attributes
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['title']).to eq('New Product')
      end
    end

    context 'when request is invalid' do
      it 'returns a 422 error' do
        post '/api/v1/products', params: { title: nil }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to include("Title can't be blank")
      end
    end
  end

  describe 'PUT /api/v1/products/:id' do
    let(:valid_attributes) { { title: 'Updated Title' } }

    context 'when product exists' do
      it 'updates the product' do
        put "/api/v1/products/#{product_id}", params: valid_attributes
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['title']).to eq('Updated Title')
      end
    end

    context 'when product does not exist' do
      it 'returns a 404 error' do
        put '/api/v1/products/0', params: valid_attributes
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Product not found')
      end
    end
  end

  describe 'DELETE /api/v1/products/:id' do
    context 'when product exists' do
      it 'deletes the product' do
        expect {
          delete "/api/v1/products/#{product_id}"
        }.to change { Product.count }.by(-1)
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']).to eq('Product deleted successfully')
      end
    end

    context 'when product does not exist' do
      it 'returns a 404 error' do
        delete '/api/v1/products/0'
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Product not found')
      end
    end
  end
end
