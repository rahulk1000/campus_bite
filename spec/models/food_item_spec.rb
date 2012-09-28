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
    @existent_categories = ['Daily Menu', 'Salad Bar', 'Condiments', 'Breads and Cereals', 'Beverages']
    @existent_dining_commons = ['Ortega', 'De La Guerra', 'Carrillo', 'Portola']
    @side_categories = ['Salad Bar', 'Condiments', 'Breads and Cereals', 'Beverages'] 
    @existent_meal_types = ['Breakfast', 'Lunch', 'Brunch', 'Dinner', 'Late Night']
  end
  
  subject { @food_item }
  
  # Should be intially valid
  it { should be_valid }
  # Test for existence of its attributes
  [:name, :dining_common, :category, :subcategory, :dining_common, :meal_type].each do |attribute|
     it { should respond_to(attribute) }
  end
  
  
  # Expectations for 'name' attribute
  describe 'validates name attribute' do
    include_examples "presence validation", :name  
    describe "when its name contains more than 200 characters (without initial and trailing whitespace)" do
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
  end 

  # Expectations for 'dining commmon' attribute 
  describe 'validates dining common attribute' do
    include_examples "presence validation", :dining_common 
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
    describe 'when its dining common consists of a existent UCSB dining common name' do
      it "should be valid" do
        @existent_dining_commons.each do |existent_dining_common|
          @food_item.dining_common = existent_dining_common
          should be_valid
        end
      end
    end
  end 

  # Expectations for 'category' attribute 
  describe 'vaidates category attribute' do
    include_examples 'presence validation', :category 
    context 'when its a existent category' do
      context "When its category is 'Daily Menu' (given date and meal type attributes are valid)" do
        before do
          @food_item.category = 'Daily Menu'
          @food_item.date = Date.today
          @food_item.meal_type = 'Lunch'
        end
        it { should be_valid }       
      end
      context "when its category is not 'Daily Menu' (given date and meal type are nil)" do
        before do
          @food_item.date = nil
          @food_item.meal_type = nil
        end
        it "should be valid" do
          @side_categories.each do |side_category|
            @food_item.category = side_category
            should be_valid
          end          
        end 
      end
      context 'when its a non-existent category' do 
        it "should be invalid for all possible given values of date and meal type (valid or nil)" do
          @food_item.category = 'Random Nonexitent Category'
          @food_item.date = Date.today
          @food_item.meal_type = 'Lunch'
          should be_invalid
          @food_item.date = nil
          @food_item.meal_type = nil
          should be_invalid             
        end            
      end     
    end   
  end  
  
  # Expectations for 'subcategory' attribute
  describe 'validates subcategory attribute' do
    include_examples 'presence validation', :subcategory
    describe 'when its subcategory contains more than 50 characters (without initial and trailing whitespace)' do
      it 'should be invalid when its subcategory contains 51 characters' do
        @food_item.subcategory = 'a' * 51
        should be_invalid
      end
    end
    describe 'when its subcategory contains less than 200 characters (with atleast one non-whitespace character)' do
      it 'should be valid when its subcategory contains 1 character' do
        @food_item.subcategory = 'a'
        should be_valid
      end
      it 'should be valid when its subcategory contains 49 characters' do
        @food_item.subcategory = 'a' * 49
        should be_valid
      end
    end  
  end
  
  # Expectations for 'meal_type' attribute
  describe 'validates meal type attribute' do
    context "when its category is 'Daily Menu'" do
      before do 
        @food_item.category = 'Daily Menu' 
        @food_item.date = Date.today
      end
      context "when its meal type is not blank" do
        context "when its meal type contains a existent meal type" do
          it 'should be valid' do
            @existent_meal_types.each do |existent_meal_type|
              @food_item.meal_type = existent_meal_type
              should be_valid
            end
          end
        end
        context "when its meal type consists a non-existent meal type" do
          it "should be invalid" do
            @food_item.meal_type = 'Supper'
            should be_invalid
            @food_item.meal_type = 'Snack'
            should be_invalid
          end       
        end
      end  
      context 'when its meal type is blank' do
        include_examples "presence validation", :meal_type
      end
    end
    context "when its category is any other existent category, aside from Daily Menu" do
      before do 
        @food_item.date = nil
      end
      context "when its meal type is not blank" do
          it 'should be invalid for all meal types (existent and non-existent)' do  
            @side_categories.each do |side_category|
              @existent_meal_types.each do |existent_meal_type|
                @food_item.meal_type = existent_meal_type
                should be_invalid
              end
              # Non-existent meal types
              @food_item.meal_type = 'Supper'
              should be_invalid
              @food_item.meal_type = 'Snack'
              should be_invalid 
            end
          end
      end 
      context "when its meal type is blank" do
        it "should be be valid when its meal type is nil" do
          @side_categories.each do |side_category|
            @food_item.category = side_category
            @food_item.meal_type = nil
            should be_valid   
          end
        end 
        it "should be invalid when its meal type is empty or contains only whitespace" do
          @side_categories.each do |side_category|
            @food_item.category = side_category
            @food_item.meal_type = ''
            should be_invalid
            @food_item.meal_type = '  '
            should be_invalid  
          end
        end   
      end
    end
  end
  
  describe 'validates date attribute' do
    context "when its category is 'Daily Menu'" do
      before do 
        @food_item.category = 'Daily Menu' 
        @food_item.meal_type = 'Lunch'
      end
      context "when its date contains a valid date" do
        it "should be valid when its date represents the current date or a date in the future" do
          # Today's date
          @food_item.date = Date.today
          should be_valid
          # Tomorrow's date
          @food_item.date = Date.tomorrow
          should be_valid
          # 5 days from today's date
          @food_item.date = Date.today + 5
          should be_valid
        end     
        it "should be invalid when its date represents a date in the past" do
          # Yesterday's date
          @food_item.date = Date.yesterday
          should be_invalid
          # 5 days before today
          @food_item.date = Date.today - 5
          should be_invalid       
        end
      end
      context "when its date does not contain a valid date" do
        it 'it should be invalid when its date is nil' do
          @food_item.date = nil
          should be_invalid
        end
        it 'should be invalid when its date contains string not representing a date' do
          @food_item.date = 'this is not a date'
          should be_invalid        
        end
        it 'should be invalid when its date contains a integer or a decemal' do
          @food_item.date = 3432
          should be_invalid
          @food_item.date = 3.432
          should be_invalid
        end     
      end 
    end
    context "when its category is any valid category, aside from 'Daily Menu'" do
      before {@food_item.meal_type = nil}
      context "when its date contains a valid date" do
        it "should  be invalid for all dates (past, present or future)" do
          @side_categories.each do |side_category| 
            @food_item.category = side_category
            # Yesterday's date
            @food_item.date = Date.yesterday
            should be_invalid
            # 5 days before today
            @food_item.date = Date.today - 5
            should be_invalid           
            # Today's date
            @food_item.date = Date.today
            should be_invalid
            # Tomorrow's date
            @food_item.date = Date.tomorrow
            should be_invalid
            # 5 days from today's date
            @food_item.date = Date.today + 5
            should be_invalid
          end
        end 
      end 
      context "when its date does not contain a valid date" do
        it 'it should be valid when its date is nil' do
          @side_categories.each do |side_category|
            @food_item.category = side_category
            @food_item.date = nil
            should be_valid
          end
        end
        it 'should be valid when its date contains string not representing a date' do
          @side_categories.each do |side_category|
            @food_item.category = side_category
            @food_item.date = 'this is not a date'
            should be_valid        
          end
        end
        it 'should be invalid when its date contains a integer or a decemal' do
          @side_categories.each do |side_category|
            @food_item.category = side_category
            @food_item.date = 3432
            should be_invalid
            @food_item.date = 3.432
            should be_invalid
          end
        end 
      end
    end
  end  
end

