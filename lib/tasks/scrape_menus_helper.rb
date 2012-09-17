# Returns a symbol after it dowcases the string and replaces whitespace with an underscore
class String
  def to_symbol
    self.downcase.gsub(/\s+/, '_').to_sym  
  end
end

def route(dining_common, category, http_request_codes) 
  throw "invalid dining common" unless [:ortega, :de_la_guerra, :carrillo, :portola].include?(dining_common)
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

end

def scrape_condiments(dining_common, category, http_request_codes) 

end

def scrape_breads_and_cereals(dining_common, category, http_request_codes) 

end

def scrape_beverages(dining_common, category, http_request_codes) 

end