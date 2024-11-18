module V1
  module Entities
    class Product < Grape::Entity
      expose :id, documentation: { type: 'Integer', desc: 'ID of the product' }
      expose :title, documentation: { type: 'String', desc: 'Title of the product' }
      expose :description, documentation: { type: 'String', desc: 'Description of the product' }
      expose :price, documentation: { type: 'Float', desc: 'Price of the product' }
      expose :stock, documentation: { type: 'Integer', desc: 'Stock count of the product' }
      expose :categories, if: { nested: true } do |product, options|
        CategoryEntity.represent(product.categories, nested: false)
      end
    end
  end
end
