# Returns a symbol after it dowcases the string and replaces whitespace with an underscore
class String
  def to_symbol
    self.downcase.gsub(/\s+/, '_').to_sym  
  end
end

def route(dining_common, category, http_request_codes) 
  case category
  when :daily_menu then scrape_daily_menu(dining_common, category, http_request_codes) 
  when :salad_bar then scrape_salad_bar(dining_common, category, http_request_codes) 
  when :condiments then scrape_condiments(dining_common, category, http_request_codes) 
  when :breads_and_cereals then scrape_breads_and_cereals(dining_common, category, http_request_codes) 
  when :beverages then scrape_beverages(dining_common, category, http_request_codes) 
  else throw "Invalid category being processsed"
  end
end


def scrape_daily_menu(dining_common, category, http_request_codes) 
end

def scrape_salad_bar(dining_common, category, http_request_codes) 
  salar_bar_file = File.open("#{Rails.root}/lib/tasks/stub_pages/ortega_salad_bar.html")
  salar_bar_doc = Nokogiri::HTML(salar_bar_file)
  salar_bar_file.close
  
  subcategory_nodes = salar_bar_doc.xpath('//table[@class="cbo_nn_itemGridTable"]/tr/' + 
                                          'td[@class="cbo_nn_itemGroupRow"]')
    next_node = nil                                   
  subcategory_nodes.each_cons(2) do |subcategory_node, next_subcategory_node|
    #(subcategory_nodes[index+1]) ? temp = subcategory_nodes[index+1].text : temp = " "
    p subcategory_node.xpath("//table[@class='cbo_nn_itemGridTable']/tr" +
                             "[td[@class='cbo_nn_itemHover']]" +
                             "[preceding-sibling::tr[td[.='#{subcategory_node.text}']]]" +
                             "[following-sibling::tr[td[.='#{next_subcategory_node.text}']]]").text                                                      
    puts "\n\n"      
    next_node = next_subcategory_node
  end
  p next_node.xpath("//table[@class='cbo_nn_itemGridTable']/tr" +
                             "[td[@class='cbo_nn_itemHover']]" +
                             "[preceding-sibling::tr[td[.='#{next_node.text}']]]").text 

=begin
  subcategory_and_item_nodes = salar_bar_doc.xpath('//table[@class="cbo_nn_itemGridTable"]' +
                                                   '/tr/td[@class="cbo_nn_itemGroupRow" or' + 
                                                   '@class="cbo_nn_itemHover"]')
  while (curr_node = subcategory_and_item_nodes.first)
    throw "error processing sub-category" if curr_node[:class] != "cbo_nn_itemGroupRow"
    # Extract sub-category name
    sub_category_name = curr_node.content.strip
    subcategory_and_item_nodes.shift
    # Extract food items in current sub-category
    while ((curr_node = subcategory_and_item_nodes.first) && curr_node[:class] == 'cbo_nn_itemHover')
      food_item = curr_node.content.strip 
      subcategory_and_item_nodes.shift
    end
  end
=end
end

def scrape_condiments(dining_common, category, http_request_codes) 

end

def scrape_breads_and_cereals(dining_common, category, http_request_codes) 

end

def scrape_beverages(dining_common, category, http_request_codes) 

end