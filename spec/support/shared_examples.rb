shared_examples "presence validation" do |attribute|
  describe "when its #{attribute} is blank" do
    it "should be be invalid when its #{attribute} is nil" do
       @food_item.send(:"#{attribute}=", nil)
       should be_invalid   
    end 
    it "should be invalid when its #{attribute} is empty" do
       @food_item.send(:"#{attribute}=", "")
       should be_invalid  
    end
    it "should be invalid when its #{attribute} contains only whitespace" do
       @food_item.send(:"#{attribute}=", " ")
       should be_invalid  
    end
  end
end

