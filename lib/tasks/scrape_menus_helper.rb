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
        yield food_item_name, subcategory_name
      end
    end
  end 
  
  def each_meal
    self.each do |meal_info_node|
      meal_date = meal_info_node.at_xpath("./tr[1]/td/text()").content.to_date
      meal_info_node.xpath("./tr[2]//a[@class='cbo_nn_menuLink']").each do |meal_type_href_element|
        meal_type = meal_type_href_element.content.strip
        meal_request_codes = meal_type_href_element[:href].strip.scan(/\d+/)
        yield meal_date, meal_type, meal_request_codes
      end
    end   
  end
  
end

def route(dining_common_name, category_name, browser, http_request_codes) 
  case category_name
  when 'Salad Bar', 'Condiments', 'Breads and Cereals', 'Beverages' 
    #fetch_food_items(dining_common_name, category_name, browser, http_request_codes)   
  when 'Daily Menu' 
    puts category_name.to_s.red
    daily_menu_file = File.open("#{Rails.root}/lib/tasks/stub_pages/ortega_daily_menu.html", 'r')
    daily_menu_doc = Nokogiri::HTML(daily_menu_file)
    daily_menu_file.close
    meals_info_nodeset = daily_menu_doc.xpath("//table[@class='cbo_nn_menuTable']/tr/" +
                                              "td[@class='cbo_nn_menuCell']/table[tr[last()=2]]")
    throw "couldnt fetch information on meals" if meals_info_nodeset.empty?
    meals_info_nodeset.each_meal do |meal_date, meal_type, meal_request_codes|
      p "#{meal_date}, #{meal_type}, #{meal_request_codes}"
    end
  else
    throw "Invalid category" 
  end
end

def fetch_food_items(dining_common_name, category_name, browser, http_request_codes)
  food_items_page = browser.post('http://netnutrition.housing.ucsb.edu/NetNutrition/Menu.aspx/OpenMenu', 
                                { unitOid: http_request_codes[0], menuOid: http_request_codes[1] })   

=begin
  salar_bar_file = File.open("#{Rails.root}/lib/tasks/stub_pages/ortega_condiments.html")
  salar_bar_doc = Nokogiri::HTML(salar_bar_file)
  salar_bar_file.close
=end
  
 # subcategories_and_items_nodeset = salar_bar_doc.xpath('//table[@class="cbo_nn_itemGridTable"]' +
                                #                           '/tr/td[@class="cbo_nn_itemGroupRow" or' + 
                                 #                          '@class="cbo_nn_itemHover"]')

  subcategories_and_items_nodeset = food_items_page.search('//table[@class="cbo_nn_itemGridTable"]' +
                                                           '/tr/td[@class="cbo_nn_itemGroupRow" or' + 
                                                           '@class="cbo_nn_itemHover"]')
  throw "couldnt fetch food items and their subcatagories" if subcategories_and_items_nodeset.empty?
  $f.puts("\n\n#{category_name} for #{dining_common_name}")
  subcategories_and_items_nodeset.each_food_item do |food_item_name, subcategory_name|
  $f.puts("\t#{food_item_name}, #{subcategory_name}")
  end
end

def fetch_food_item_page(browser, http_request_codes)

end


def scrape_salad_bar(dining_common, category, browser, http_request_codes) 
                                             
end
# TODO: sanitize function for scraped content (removing non breaking spaced etc)
# TODO: place all class extesions somewhere else?

