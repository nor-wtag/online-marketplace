class OrderMailer < ApplicationMailer
  default from: 'online_marketplace@mail.com'

  def order_placed_email(order)
    @order = order
    mail(to: @order.buyer.email, subject: 'Your Order Confirmation')
  end
end
