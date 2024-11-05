class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?  # return if no user is signed in

    case user.role
    when 'admin'
      can :manage, :all
      can :destroy, User, id: user.id
    when 'seller'
      can :create, Product
      can :read, Product
      can :update, Product, user_id: user.id
      can :destroy, Product, user_id: user.id
      can :delete, Product, user_id: user.id

      can :read, Category

      can :destroy, User, id: user.id
      can :delete, User, id: user.id
    when 'buyer'
      can :read, Product
      can :read, Category
      can :destroy, User, id: user.id
    when 'rider'
    end
  end
end
