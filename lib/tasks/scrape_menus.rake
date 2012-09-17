require_relative 'scrape_menus_helper'
desc 'Scrapes menu items from all the dining commons at UCSB'
task :scrape_menus => :environment do
  # Hash containg ids to make HTTP requests
  menu_home_file = File.open("#{Rails.root}/lib/tasks/stub_pages/menu_home_page.html")
  menu_home_doc = Nokogiri::HTML(menu_home_file)
  menu_home_file.close
  dining_commons_nodeset = menu_home_doc.xpath('//ul[@class="cbo_nn_unitTreeListDiv"]' +
                                                '/li[@class="cbo_nn_unitTreeParent"]')  
  throw "Error scraping information about the dining commons" if dining_commons_nodeset.size != 4
  # Iterate through the each dining common
  dining_commons_nodeset.each_with_index do |dining_common_node, dining_common_index|
    dining_common_name = dining_common_node.child.content.strip
    categories_nodeset = dining_common_node.xpath('./ul/li[@class="cbo_nn_unitTreeParentNoChild"]')
    throw "Error scrapping categories" if categories_nodeset.size != 5      
    # Iterate through each category of the current dining common
    categories_nodeset.each_with_index do |category, category_index|
      category_href_element = category.first_element_child
      category_name = category_href_element.content.strip
      category_name = 'Daily Menu'  if category_name.include?('Daily Menu') 
      http_request_codes = category_href_element[:href].strip.scan(/\d+/)     
      route(dining_common_name.to_symbol, category_name.to_symbol, http_request_codes)
    end
  end
end
