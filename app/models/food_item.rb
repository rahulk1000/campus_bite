# == Schema Information
#
# Table name: food_items
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  dining_common :string(255)
#  category      :string(255)
#  subcategory   :string(255)
#  date          :date
#  meal_type     :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class FoodItem < ActiveRecord::Base
  attr_accessible :category, :date, :dining_common, :meal_type, :name, :subcategory
  before_validation :strip_whitespace
  validates :name, presence: true, length: { maximum: 200 }
  validates :dining_common, inclusion: { in: ['Ortega', 'De La Guerra', 'Carrillo', 'Portola'],
                                         message: "%{value} is not a valid dining common" }
  validates :category, inclusion: { in: ['Daily Menu', 
                                         'Salad Bar', 
                                         'Condiments', 
                                         'Breads and Cereals', 
                                         'Beverages'], message: "%{value} is not a valid category" }
  #validates :subcategory, presence: true, length: { maximum: 50 }
                                        
  protected
  def strip_whitespace
    self.name = name.to_s.strip
    self.dining_common = dining_common.to_s.strip
    self.category = category.to_s.strip
    self.subcategory = subcategory.to_s.strip
    self.meal_type = meal_type.to_s.strip
  end
                      

end
