desc 'Scrapes menu items from all the dining commons at UCSB'
task :scrape_menus => :environment do
  # Hash containg ids to make HTTP requests
  http_request_info = { ortega: { },
                        de_la_guerra: { },
                        carrillo: { },
                        portola: { },
                      }
  menu_home_file = File.open("#{Rails.root}/lib/tasks/stub_pages/menu_home_page.html")
  menu_home_doc = Nokogiri::HTML(menu_home_file)
  menu_home_file.close
  dining_commons_info_nodeset = menu_home_doc.xpath('//ul[@class="cbo_nn_unitTreeListDiv"]' +
                                                     '/li[@class="cbo_nn_unitTreeParent"]')  
  throw "Error scraping information about the dining commons" if dining_commons_info_nodeset.size != 4
  dining_commons_info_nodeset.each do |dining_commons_info_node|
    hash_symbol = dining_commons_info_node.child.content.strip.downcase.gsub(/\s+/, '_').to_sym
    throw "Incosistencies in dinning commons names" if http_request_info[hash_symbol].nil?
    categories_nodeset = dining_commons_info_node.xpath('./ul/li[@class="cbo_nn_unitTreeParentNoChild"]')
    categories_nodeset.shift
    p unit_id = categories_nodeset.shift.first_element_child[:href].scan(/\d+/)
  end
end
