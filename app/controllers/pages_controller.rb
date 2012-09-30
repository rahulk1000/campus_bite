class PagesController < ApplicationController
  respond_to :html, :js
  def home
    @food_items = if params[:search].blank?
                    [ ]
                  else
                    FoodItem.search_by_name(params[:search]).
                             where("date >= ? OR date IS ?", Date.today, nil).
                            order("name ASC")
                  end
                
    respond_with(@food_items)
  end
  def items
  end
end

