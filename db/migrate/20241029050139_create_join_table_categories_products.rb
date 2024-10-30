class CreateJoinTableCategoriesProducts < ActiveRecord::Migration[7.2]
  def change
    # create_table :categories do |t|
    #   t.string :name
    #   t.text :description
    #   t.timestamps
    # end

    # create_table :products do |t|
    #   t.string :title
    #   t.text :description
    #   t.decimal :price
    #   t.integer :stock
    #   t.timestamps
    # end

    create_join_table :categories, :products do |t|
      t.index :category_id
      t.index :product_id
      t.index [ :category_id, :product_id ], unique: true
    end
  end

  #     # add_index("categories_products", [ :category_id, :product_id ])
  #   # end
end
