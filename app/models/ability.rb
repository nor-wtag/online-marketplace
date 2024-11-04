class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.seller?
      can [:create, :read, :update, :destroy, :delete], Product, user_id: user.id
      can [:create, :read, :update, :destroy, :delete], Category
    elsif user.buyer?
      can :read, Product
      can :read, Category
    elsif user.admin?
      can :manage, :all
    elsif user.rider?
      can :read, Order, rider_id: user.id
    end

    # can :read, Product
    # can :read, Category
  end
end
