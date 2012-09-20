# Returns a symbol after it dowcases the string and replaces whitespace with an underscore
class String
  def to_symbol
    self.downcase.gsub(/\s+/, '_').to_sym  
  end
end

class Nokogiri::XML::NodeSet  
  def each_food_item
    subcategory_name = nil                                                
    self.each do |current_node|
      # 'current_node' can contain either a subcategory or a food item
      if current_node[:class] == "cbo_nn_itemGroupRow" 
        subcategory_name = current_node.content.strip
      elsif current_node[:class] == 'cbo_nn_itemHover'
        food_item_name = current_node.content.strip 
        yield(food_item_name, subcategory_name)
      end
    end
  end 
end

def route(dining_common, category, browser, http_request_codes)  
  case category
  when :daily_menu then scrape_daily_menu(dining_common, category, http_request_codes) 
  when :salad_bar then scrape_salad_bar(dining_common, category, browser, http_request_codes) 
  when :condiments then scrape_condiments(dining_common, category, http_request_codes) 
  when :breads_and_cereals then scrape_breads_and_cereals(dining_common, category, http_request_codes) 
  when :beverages then scrape_beverages(dining_common, category, http_request_codes) 
  else throw "Invalid category being processsed"
  end
end

def fetch_food_item_page(browser, http_request_codes)
  food_item_page = browser.post('http://netnutrition.housing.ucsb.edu/NetNutrition/Menu.aspx/OpenMenu', 
                                { unitOid: http_request_codes[0], menuOid: http_request_codes[1] })   
end

def scrape_daily_menu(dining_common, category, http_request_codes) 
end

def scrape_salad_bar(dining_common, category, browser, http_request_codes) 
  salad_bar_page = fetch_food_item_page(browser, http_request_codes)
=begin
  salar_bar_file = File.open("#{Rails.root}/lib/tasks/stub_pages/ortega_condiments.html")
  salar_bar_doc = Nokogiri::HTML(salar_bar_file)
  salar_bar_file.close
=end
  subcategories_and_items_nodeset = salad_bar_page.search('//table[@class="cbo_nn_itemGridTable"]' +
                                                          '/tr/td[@class="cbo_nn_itemGroupRow" or' + 
                                                          '@class="cbo_nn_itemHover"]')
  throw "couldnt fetch food items and their subcatagories" if subcategories_and_items_nodeset.empty?
  puts "Salad Bar for #{dining_common}".blue
  subcategories_and_items_nodeset.each_food_item do |food_item_name, subcategory_name|
    puts "#{food_item_name}, " + "#{subcategory_name}".yellow
  end                                               
end

def scrape_condiments(dining_common, category, http_request_codes) 

end

def scrape_breads_and_cereals(dining_common, category, http_request_codes) 

end

def scrape_beverages(dining_common, category, http_request_codes) 

end