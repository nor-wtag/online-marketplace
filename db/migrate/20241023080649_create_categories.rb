class CreateCategories < ActiveRecord::Migration[7.2]
  def up
    create_table :categories do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end

  def down
    drop_table :categories
  end
end
