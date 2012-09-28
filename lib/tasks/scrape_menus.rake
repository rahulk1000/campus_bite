require_relative 'scrape_menus_helper'
desc 'Scrapes menu items from all the dining commons at UCSB'
task :scrape_menus => :environment do
  MENU_HOME_URL = 'http://netnutrition.housing.ucsb.edu/NetNutrition/Home.aspx'
  REQUEST_INFO_URL = 'http://netnutrition.housing.ucsb.edu/NetNutrition/Unit.aspx/SetUnitTreeUnitState'                                           
  CATEGORY_URL = 'http://netnutrition.housing.ucsb.edu/netnutrition/Unit.aspx/SelectUnitFromTree'
  DAILY_MENU_URL = 'http://netnutrition.housing.ucsb.edu/netnutrition/Menu.aspx/SelectMenu'
  $f = File.open("#{Rails.root}/lib/tasks/output.txt", 'w')
  browser = Mechanize.new do |a| 
    a.user_agent = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:13.0) Gecko/20100101 Firefox/13.0.1'
  end
  # Fetch menu home page, set session cookie in 'browser'
  menu_home_page = browser.get(MENU_HOME_URL)   
  
  #dining_commons_info_doc = Nokogiri::HTML(File.open("#{Rails.root}/lib/tasks/stub_pages/dining_commons_info.html"))  
  # Fetch all nodesets containg information on each of the dining commons
  dining_commons_nodeset = menu_home_page.search("//ul[@class='cbo_nn_unitTreeListDiv']/li" +
                                                 "[@class='expanded'][a[.='Ortega' or " + 
                                                 ".='De La Guerra' or .='Carrillo' or .='Portola']]" +
                                                 "[ul][last()=4]")
  throw "error fetching dining commons information" if dining_commons_nodeset.empty?
  # Iterate through the each dining common
  dining_commons_nodeset.each do |dining_common_node|
    # Extract dining common's name 
    dining_common_name = dining_common_node.at_xpath('./a/text()').content
    categories_nodeset = dining_common_node.xpath("./ul/li[last()=5]/a[contains(.,'Daily Menu') or " + 
                                                  ".='Salad Bar' or .='Condiments' or " +
                                                  ".='Breads and Cereals' or .='Beverages']")
    throw "Error scrapping categories" if categories_nodeset.empty?    
    # Iterate through each category of the current dining common
    categories_nodeset.each do |category_node|
      # Extract category name, and code needed to request food items/menus in that category via HTTP POST
      category_name = category_node.content.include?('Daily Menu') ? 'Daily Menu' : category_node.content  
      category_request_code = category_node[:onclick][/\d+/]
      puts "#{dining_common_name}, #{category_name}, #{category_request_code}"
      #route(dining_common_name, category_name, browser, category_request_code)
    end
  end
  $f.close
end




