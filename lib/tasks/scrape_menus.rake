require_relative 'scrape_menus_helper'
desc 'Scrapes menu items from all the dining commons at UCSB'
task :scrape_menus => :environment do
  $f = File.open("#{Rails.root}/lib/tasks/output.txt", 'w')
  menu_home_file = File.open("#{Rails.root}/lib/tasks/stub_pages/menu_home_page.html")
  menu_home_doc = Nokogiri::HTML(menu_home_file)
  menu_home_file.close
  
  browser = Mechanize.new do |a| 
    a.user_agent = 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:13.0) Gecko/20100101 Firefox/13.0.1'
  end
  # Fetch menu home page. Also sets session cookie in 'browser'
  #browser.get('http://netnutrition.housing.ucsb.edu/NetNutrition/Home.aspx') 
  
  dining_commons_nodeset = menu_home_doc.xpath('//ul[@class="cbo_nn_unitTreeListDiv"]' +
                                                '/li[@class="cbo_nn_unitTreeParent"]')  
  throw "Error scraping information about the dining commons" if dining_commons_nodeset.size != 4
  # Iterate through the each dining common
=begin
  dining_commons_nodeset.each do |dining_common_node|
    # Extract dining common's name and convert it into a symbol
    dining_common_name = dining_common_node.child.content.strip
    unless ['Ortega', 'De La Guerra', 'Carrillo', 'Portola'].include?(dining_common_name)
      throw "invalid dining common symbol" 
    end
    categories_nodeset = dining_common_node.xpath('./ul/li[@class="cbo_nn_unitTreeParentNoChild"]')
    throw "Error scrapping categories" if categories_nodeset.size != 5      
    # Iterate through each category of the current dining common
    categories_nodeset.each do |category|
      category_href_element = category.first_element_child
      # Extract category name and convert it into a symbol
      category_name = category_href_element.content.strip
      # Converting "(Dining Common name)'s Daily Menu" to simply "Daily Menu"
      category_name = 'Daily Menu'  if category_name.include?('Daily Menu') 
      http_request_codes = category_href_element[:href].strip.scan(/\d+/)
      route(dining_common_name, category_name, browser, http_request_codes)
    end
  end
=end
  route('Ortega', 'Daily Menu', browser, [1, 2])
 $f.close
end




