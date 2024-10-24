class RemoveCommentableFromReviews < ActiveRecord::Migration[7.2]
  def change
    remove_reference :reviews, :commentable, polymorphic: true, null: false
  end
end
