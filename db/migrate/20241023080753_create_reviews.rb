class CreateReviews < ActiveRecord::Migration[7.2]
  def up
    create_table :reviews do |t|
      t.integer :rating
      t.text :comment
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end

  def down
    drop_table :reviews
  end
end
