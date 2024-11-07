class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    case user.role
    when 'admin'
      can :manage, :all

    when 'seller'
      can :create, Product
      can :read, Product
      can :update, Product, user_id: user.id
      can :destroy, Product, user_id: user.id
      can :delete, Product, user_id: user.id

      can :read, Category

      can :read, Review, product: { user_id: user.id }
      can [ :read, :update, :destroy ], User, id: user.id

      can :read, Order, order_items: { product: { user_id: user.id } }
      can :read, OrderItem, order: { order_items: { product: { user_id: user.id } } }
      can :update_status, OrderItem, product: { user_id: user.id }

    when 'buyer'
      can :read, Product
      can :read, Category

      can :create, Review
      can :read, Review
      can [ :update, :destroy ], Review, user_id: user.id

      can :create, Cart
      can :read, Cart, user_id: user.id
      can :update, Cart, user_id: user.id
      can :destroy, Cart, user_id: user.id

      can :create, CartItem, cart: { user_id: user.id }
      can :read, CartItem, cart: { user_id: user.id }
      can :update, CartItem, cart: { user_id: user.id }
      can :destroy, CartItem, cart: { user_id: user.id }

      can :create, Order
      can :read, Order, user_id: user.id
      can :update, Order, user_id: user.id
      can :cancel, Order, user_id: user.id

      can :create, OrderItem
      can :read, OrderItem, order: { user_id: user.id }
      can :update, OrderItem, order: { user_id: user.id }
      can :destroy, OrderItem, order: { user_id: user.id }

      can [ :read, :update, :destroy ], User, id: user.id

    end
  end
end
