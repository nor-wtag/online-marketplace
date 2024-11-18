module ApplicationHelper
  def format_price(amount)
    number_to_currency(amount, unit: "৳", delimiter: ",")
  end
end
