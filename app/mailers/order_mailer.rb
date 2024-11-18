class OrderMailer < ApplicationMailer
  default from: 'no-reply@yourapp.com'

  def order_placed_email(order)
    @order = order
    mail(to: @order.buyer.email, subject: 'Your Order Confirmation')
  end
end
