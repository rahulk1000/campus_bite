class PagesController < ApplicationController
  def home
    if params[:search].nil?
      render inline: "", layout: 'application'  
    else
      @food_items = params[:search].blank? ? [] : FoodItem.search_by_name(params[:search]).where("date >= ? OR date IS ?", Date.today, nil)
    end
  end
  def items
  end
end

