class PagesController < ApplicationController
  respond_to :html, :js
  helper_method :sort_column, :sort_direction
  def home
    @food_items = if params[:search].blank?
                    [ ]
                  else
                    FoodItem.order(sort_column + ' ' + sort_direction).
                             search_by_name(params[:search]).
                             where("date >= ? OR date IS ?", Date.today, nil)                            
                  end
                
    respond_with(@food_items)
  end
  
  def items
    
  end
  
  private
  def sort_column
    %w[name date dining_common].include?(params[:sort]) ? params[:sort] : 'date'
  end
  def sort_direction 
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end   
end

