class PagesController < ApplicationController
  def home
    if params[:search].nil?
      render inline: "", layout: 'application'  
    else
      @food_items = if params[:search].blank? 
        [] 
      else 
        FoodItem.search_by_name(params[:search]).
                 where("date >= ? OR date IS ?", Date.today, nil).
                 order("name ASC")
      end       
    end
  end
  def items
  end
end

