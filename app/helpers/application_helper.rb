module ApplicationHelper
  def sort_link(column, title)
    if column == sort_column
      arrow_icon = if sort_direction == 'asc'  
                      content_tag(:i,nil,class: 'icon-arrow-up')
                    else
                      content_tag(:i,nil,class: 'icon-arrow-down')
                    end

    end
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to({ search: params[:search], sort: column, direction: direction }, remote: true) do
      arrow_icon.to_s + title +  arrow_icon.to_s
    end 
  end
end
