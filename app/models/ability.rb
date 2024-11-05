class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present? # Return if no user is signed in

    case user.role
    when 'admin'
      can :manage, :all

    when 'seller'
      can :create, Product
      can :read, Product
      can :update, Product, user_id: user.id
      can :destroy, Product, user_id: user.id

      # Sellers can read reviews of products they own
      can :read, Review, product: { user_id: user.id }

    when 'buyer'
      can :read, Product
      can :read, Category

      # Buyers can create, read, update, and destroy their own reviews
      can :create, Review
      can [:read, :update, :destroy], Review, user_id: user.id

      # Additional cart permissions for buyers
      can :create, Cart
      can :read, Cart, user_id: user.id
      can :update, Cart, user_id: user.id
      can :destroy, Cart, user_id: user.id
      
      can :create, CartItem, cart: { user_id: user.id }
      can :read, CartItem, cart: { user_id: user.id }
      can :update, CartItem, cart: { user_id: user.id }
      can :destroy, CartItem, cart: { user_id: user.id }

    end
  end
end
