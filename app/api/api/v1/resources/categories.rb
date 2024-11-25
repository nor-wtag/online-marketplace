module V1
  module Resources
    class Categories < Grape::API
      version 'v1', using: :path
      format :json
      prefix :api

      resource :categories do
        desc 'Get all categories'
        get do
          categories = Category.all
          present categories, with: V1::Entities::Category
        end

        desc 'Get a single category'
        params do
          requires :id, type: Integer, desc: 'Category ID'
        end
        get ':id' do
          category = Category.find(params[:id])
          present category, with: V1::Entities::Category
        rescue ActiveRecord::RecordNotFound
          error!({ error: 'Category not found' }, 404)
        end

        desc 'Create a new category'
        params do
          requires :name, type: String, desc: 'Name of the category'
          requires :description, type: String, desc: 'Description of the category'
          optional :product_ids, type: Array[Integer], desc: 'IDs of associated products'
        end
        post do
          category = Category.new(declared(params))
          if category.save
            present category, with: V1::Entities::Category
          else
            error!({ error: category.errors.full_messages }, 422)
          end
        end

        desc 'Update a category'
        params do
          requires :id, type: Integer, desc: 'Category ID'
          optional :name, type: String, desc: 'Name of the category'
          optional :description, type: String, desc: 'Description of the category'
          optional :product_ids, type: Array[Integer], desc: 'IDs of associated products'
        end
        put ':id' do
          category = Category.find(params[:id])
          if category.update(declared(params, include_missing: false))
            present category, with: V1::Entities::Category
          else
            error!({ error: category.errors.full_messages }, 422)
          end
        rescue ActiveRecord::RecordNotFound
          error!({ error: 'Category not found' }, 404)
        end

        desc 'Delete a category'
        params do
          requires :id, type: Integer, desc: 'Category ID'
        end
        delete ':id' do
          category = Category.find(params[:id])
          category.destroy
          { message: 'Category deleted successfully' }
        rescue ActiveRecord::RecordNotFound
          error!({ error: 'Category not found' }, 404)
        end
      end
    end
  end
end
