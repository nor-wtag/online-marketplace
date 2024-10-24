class AddCommentableToReviews < ActiveRecord::Migration[7.2]
  def change
    add_reference :reviews, :commentable, polymorphic: true, null: false
  end
end
