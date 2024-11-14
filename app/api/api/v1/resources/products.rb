module V1
  module Resources
    class Products < Grape::API
      version 'v1', using: :path
      format :json
      prefix :api

      resource :products do
        desc 'Get all products'
        get do
          products = Product.all
          present products, with: V1::Entities::Product
        end

        desc 'Get a single product'
        params do
          requires :id, type: Integer, desc: 'Product ID'
        end
        get ':id' do
          product = Product.find(params[:id])
          present product, with: V1::Entities::Product
        rescue ActiveRecord::RecordNotFound
          error!({ error: 'Product not found' }, 404)
        end

        desc 'Create a new product'
        params do
          requires :title, type: String, desc: 'Title of the product'
          requires :description, type: String, desc: 'Description of the product'
          requires :price, type: Float, desc: 'Price of the product'
          requires :stock, type: Integer, desc: 'Stock count of the product'
          optional :category_ids, type: Array[Integer], desc: 'IDs of associated categories'
        end
        post do
          product = Product.new(declared(params))
          if product.save
            present product, with: V1::Entities::Product
          else
            error!({ error: product.errors.full_messages }, 422)
          end
        end

        desc 'Update a product'
        params do
          requires :id, type: Integer, desc: 'Product ID'
          optional :title, type: String, desc: 'Title of the product'
          optional :description, type: String, desc: 'Description of the product'
          optional :price, type: Float, desc: 'Price of the product'
          optional :stock, type: Integer, desc: 'Stock count of the product'
          optional :category_ids, type: Array[Integer], desc: 'IDs of associated categories'
        end
        put ':id' do
          product = Product.find(params[:id])
          if product.update(declared(params, include_missing: false))
            present product, with: V1::Entities::Product
          else
            error!({ error: product.errors.full_messages }, 422)
          end
        rescue ActiveRecord::RecordNotFound
          error!({ error: 'Product not found' }, 404)
        end

        desc 'Delete a product'
        params do
          requires :id, type: Integer, desc: 'Product ID'
        end
        delete ':id' do
          product = Product.find(params[:id])
          product.destroy
          { status: 'Product deleted successfully' }
        rescue ActiveRecord::RecordNotFound
          error!({ error: 'Product not found' }, 404)
        end
      end
    end
  end
end
