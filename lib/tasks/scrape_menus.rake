require_relative 'scrape_menus_helper'
desc 'Scrapes menu items from all the dining commons at UCSB'
task :scrape_menus => :environment do
  menu_home_file = File.open("#{Rails.root}/lib/tasks/stub_pages/menu_home_page.html")
  menu_home_doc = Nokogiri::HTML(menu_home_file)
  menu_home_file.close
  dining_commons_nodeset = menu_home_doc.xpath('//ul[@class="cbo_nn_unitTreeListDiv"]' +
                                                '/li[@class="cbo_nn_unitTreeParent"]')  
  throw "Error scraping information about the dining commons" if dining_commons_nodeset.size != 4
  # Iterate through the each dining common
=begin
  dining_commons_nodeset.each_with_index do |dining_common_node, dining_common_index|
    # Extract dining common's name and convert it into a symbol
    dining_common_sym = dining_common_node.child.content.strip.to_symbol
    unless [:ortega, :de_la_guerra, :carrillo, :portola].include?(dining_common_sym)
      throw "invalid dining common symbol" 
    end
    categories_nodeset = dining_common_node.xpath('./ul/li[@class="cbo_nn_unitTreeParentNoChild"]')
    throw "Error scrapping categories" if categories_nodeset.size != 5      
    # Iterate through each category of the current dining common
    categories_nodeset.each_with_index do |category, category_index|
      category_href_element = category.first_element_child
      # Extract category name and convert it into a symbol
      category_name = category_href_element.content.strip
      category_name = 'Daily Menu'  if category_name.include?('Daily Menu') 
      category_sym = category_name.to_symbol
      http_request_codes = category_href_element[:href].strip.scan(/\d+/)     
      route(dining_common_sym, category_sym, http_request_codes)
    end
  end
=end
  scrape_salad_bar(:ortega, :salad_bar, [])
end
