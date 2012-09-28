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
class ValidDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.class == Date && value >= Date.today
      record.errors[attribute] << ('is not current or future date')
    end
  end
end
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
                                         'Beverages'], 
                                    message: "%{value} is not a valid category" }
  validates :subcategory, presence: true, length: { maximum: 50 }
  validates :meal_type, inclusion: { in: ['Breakfast', 'Brunch', 'Lunch', 'Dinner', 'Late Night'], 
                                     message: "%{value} is not a valid meal type" }, 
                        allow_nil: true  
  validates :date, valid_date: true, allow_nil: true
  
  validate :daily_menu_item_must_have_non_nil_meal_type, 
           :daily_menu_item_must_have_non_nil_date

  

  protected
  def strip_whitespace
    self.name = name.to_s.strip
    self.dining_common = dining_common.to_s.strip
    self.category = category.to_s.strip
    self.subcategory = subcategory.to_s.strip
    self.meal_type = meal_type.to_s.strip if !meal_type.nil?
  end 
  def daily_menu_item_must_have_non_nil_meal_type
    if (category=='Daily Menu' && meal_type.nil?) || (category!='Daily Menu' && !meal_type.nil?)
      errors.add(:meal_type, "should contain a meal type if and only if category is 'Daily Menu', should be nil for all other categories")     
    end
  end
  def daily_menu_item_must_have_non_nil_date
    if category=='Daily Menu' && date.nil? || (category!='Daily Menu' && !date.nil?)
      errors.add(:date, "should contain a date if and only if category is 'Daily Menu', should be nil for all other categories")     
    end
  end
end
