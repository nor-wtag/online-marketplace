class SendOrderConfirmationJob < ApplicationJob
  queue_as :mailers

  def perform(order_id)
    order = Order.find(order_id)
    OrderMailer.order_placed_email(order).deliver_now
  end
end
