class Mechanize
  # Executes HTTP request based on url and query provided, then parses the JSON result to extract 
  # HTML from the panel specified
    def post_extract_html(url, query = {}, options)
    result_json = self.post(url, query).content
    JSON.parse(result_json)['panels'].each { |panel| return panel['html'] if panel['id'] == options[:panel_id] }
    throw "couldnt convert json to html"  
  end  
end

class Nokogiri::XML::NodeSet  
  # Iterator for nodesets containing food items and their subcategories
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
  # Iterator for nodesets containing information on daily menus
  def each_menu
    self.each do |menu_info_node|
      menu_date = menu_info_node.at_xpath("./tr[1]/td/text()").content.to_date
      menu_info_node.xpath("./tr[2]//a[@class='cbo_nn_menuLink']").each do |menu_info_a_element|
        menu_type = menu_info_a_element.content.strip
        menu_request_code = menu_info_a_element[:onclick][/\d+/]
        yield menu_date, menu_type, menu_request_code
      end
    end   
  end
end

# Fetches food items based on the name of the category provided
def route(dining_common_name, category_name, browser, category_request_code) 
  # If the category is 'Daily Menu', making a HTTP POST with the category request code will return
  # information regarding all the menus for the current week. If the category is 'Salad Bar', 'Condiments', 
  # 'Breads and Cereals' or 'Beverages', making a HTTP post with the category request code
  # will return all the food items corresponding to that category
  case category_name
  when 'Salad Bar', 'Condiments', 'Breads and Cereals', 'Beverages'
    food_items_html = browser.post_extract_html(CATEGORY_URL, 
                                                { unitOid: category_request_code }, 
                                                panel_id: 'itemPanel')
    fetch_food_items(food_items_html, dining_common_name: dining_common_name, category_name: category_name) 
  when 'Daily Menu' 
    daily_menus_html = browser.post_extract_html(CATEGORY_URL, 
                                                 { unitOid: category_request_code }, 
                                                 panel_id: 'menuPanel')
    daily_menus_doc = Nokogiri::HTML(daily_menus_html)
    # Obtain all the information regarding the menus for the current week. The information 
    # cosists of a date (when food items in the menu will be served), type (Lunch, Dinner etc), and  a 
    # request code (used to fetch the food items for a paricular menu via HTTP POST )
    daily_menus_nodeset = daily_menus_doc.xpath("//table[@class='cbo_nn_menuTable']/tr/" +
                                                "td[@class='cbo_nn_menuCell']/table[tr[last()=2]]")
    throw "couldnt fetch information on meals" if daily_menus_nodeset.empty?
    # Fetch food items for each menu
    daily_menus_nodeset.each_menu do |menu_date, menu_type, menu_request_code|
      #p "#{menu_date}, #{menu_type}, #{menu_request_code}"
      food_items_html = browser.post_extract_html(DAILY_MENU_URL, 
                                                  { menuOid: menu_request_code }, 
                                                  panel_id: 'itemPanel')
      fetch_food_items(food_items_html, dining_common_name: dining_common_name, 
                                        category_name: category_name,
                                        menu_date: menu_date, 
                                        menu_type: menu_type) 
    end
  else
    throw "Invalid category" 
  end
end
# Extract food items and their subcategories from HTML, and insert them (along with information 
# provided in options hash) into database table 
def fetch_food_items(food_items_html, options)
  food_items_doc = Nokogiri::HTML(food_items_html)
  subcategories_and_items_nodeset = food_items_doc.xpath('//table[@class="cbo_nn_itemGridTable"]' +
                                                          '/tr/td[@class="cbo_nn_itemGroupRow" or' + 
                                                          '@class="cbo_nn_itemHover"]')
  throw "couldnt fetch food items and their subcatagories" if subcategories_and_items_nodeset.empty?
  $f.puts("\n\n#{options[:category_name]} for #{options[:dining_common_name]} at #{options[:menu_date]} : #{options[:menu_type]}")
  subcategories_and_items_nodeset.each_food_item do |food_item_name, subcategory_name|
    $f.puts("\t#{food_item_name}, #{subcategory_name}") 
  end
end

# TODO: sanitize function for scraped content (removing non breaking spaced etc)
# TODO: place all class extesions somewhere else?
# TODO: use watir or capybara to click dining common link and let javascript run


