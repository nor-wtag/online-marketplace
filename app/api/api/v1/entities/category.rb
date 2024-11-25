module V1
  module Entities
    class Category < Grape::Entity
      expose :id, documentation: { type: 'Integer', desc: 'ID of the category' }
      expose :name, documentation: { type: 'String', desc: 'Name of the category' }
      expose :description, documentation: { type: 'String', desc: 'Description of the category' }
      expose :products, using: V1::Entities::Product, documentation: { type: 'Array', desc: 'Associated products' }
    end
  end
end
