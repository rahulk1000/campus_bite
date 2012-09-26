class CreateFoodItems < ActiveRecord::Migration
  def change
    create_table :food_items do |t|
      t.string :name
      t.string :dining_common
      t.string :category
      t.string :subcategory
      t.date :date
      t.string :meal_type

      t.timestamps
    end
  end
end
