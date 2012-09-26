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

require 'spec_helper'

describe FoodItem do
  before do 
    @food_item = FoodItem.new(name: 'Chicken Tostadas', 
                              dining_common: 'De La Guerra',
                              category: 'Daily Menu',
                              subcategory: 'East Side',
                              date: Date.today,
                              meal_type: 'Lunch')                                   
  end
  
  subject { @food_item }
  
  # Test for existence of its attributes
  it { should respond_to(:name) }
  it { should respond_to(:dining_common) }
  it { should respond_to(:category) }
  it { should respond_to(:subcategory) }
  it { should respond_to(:date) }
  it { should respond_to(:meal_type) }
  
  
  # Expectations for 'name' attribute 
  describe 'when its name is nil, empty, or contains only whitespace' do
    it 'should be invalid when its name is nil' do
      @food_item.name = nil
      should be_invalid
    end
    it 'should be invalid when its name is empty' do
      @food_item.name = ""
      should be_invalid
    end
    it 'should be invalid when its name is contains only whitespace' do
      @food_item.name = " "
      should be_invalid
    end
  end
  
  describe "when its name contains more than 200 characters" do
    it 'should be invalid when its name contains 201 characters' do
      @food_item.name = 'a' * 201
      should be_invalid
    end
  end
  describe "when its name contains less than 200 characters (with atleast one non-whitespace character)" do
    it 'should be valid when its name contains 1 characters' do
      @food_item.name = 'a'
      should be_valid
    end
    it 'should be valid when its name contains 199 characters' do
      @food_item.name = 'a' * 199
      should be_valid
    end
  end
  
  # Expectations for 'dining commmon' attribute 
  describe 'when its dining common is nil, empty, or contains only whitespace' do
    it 'should be invalid when its dining common is nil' do
      @food_item.dining_common = nil
      should be_invalid
    end
    it 'should be invalid when its dining common is empty' do
      @food_item.dining_common = ""
      should be_invalid
    end
    it 'should be invalid when its dining common is contains only whitespace' do
      @food_item.dining_common = " "
      should be_invalid
    end
  end
  
  describe 'when its dining common consists of a non existent UCSB dining common name' do
    it "should be invalid when its dining common consists of 'UCen'" do
      @food_item.dining_common = 'Ucen'
      should be_invalid
    end
    it "should be invalid when its dining common consists of 'Subway'" do
      @food_item.dining_common = 'Subway'
      should be_invalid
    end
  end
  
  describe 'when its dining common consists of a UCSB dining common name' do
    it "should be valid when its dining common is 'Ortega'" do
      @food_item.dining_common = 'Ortega'
      should be_valid
    end
    it "should be valid when its dining common is 'De La Guerra'" do
      @food_item.dining_common = 'De La Guerra'
      should be_valid
    end
    it "should be valid when its dining common is 'Carrillo'" do
      @food_item.dining_common = 'Carrillo'
      should be_valid
    end
    it "should be valid when its dining common is 'Portola'" do
      @food_item.dining_common = 'Portola'
      should be_valid
    end
  end
  
  # Expectations for 'category attribute 
  describe 'when its category is nil, empty, or contains only whitespace' do
    it 'should be invalid when its category is nil' do
      @food_item.category = nil
      should be_invalid
    end
    it 'should be invalid when its category is empty' do
      @food_item.category = ""
      should be_invalid
    end
    it 'should be invalid when its category is contains only whitespace' do
      @food_item.category = " "
      should be_invalid
    end
  end
  
  describe 'when its category consists of a non-existent category' do
    it "should be invalid when its category is 'Soups and Salads'" do
      @food_item.category = 'Soups and Salads'
      should be_invalid
    end    
    it "should be invalid when its category is 'Appetizers'" do
      @food_item.category = 'Appertizers'
      should be_invalid
    end   
  end
  
  describe 'when its category consists of a existent category' do
    it "should be valid when its category is 'Daily Menu'" do
      @food_item.category = 'Daily Menu'
      should be_valid
    end
    it "should be valid when its category is 'Salad Bar'" do
      @food_item.category = 'Salad Bar'
      should be_valid
    end
    it "should be valid when its category is 'Condiments'" do
      @food_item.category = 'Condiments'
      should be_valid
    end    
    it "should be valid when its category is 'Breads and Cereals'" do
      @food_item.category = 'Breads and Cereals'
      should be_valid
    end
    it "should be valid when its category is 'Beverages'" do
      @food_item.category = 'Beverages'
      should be_valid
    end
  end
  
end

