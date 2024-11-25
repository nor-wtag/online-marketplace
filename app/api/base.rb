# app/api/base.rb
class Base <Grape::API
  mount V1::Resources::Products
  mount V1::Resources::Categories
  # mount V1::Resources::Reviews
  # mount V1::Resources::Orders
  # mount V1::Resources::Carts
end
