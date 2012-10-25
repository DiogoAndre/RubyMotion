describe "iOS constants" do
  it "have their values retrieved at demand" do
    ABAddressBookCreate()
    KABPersonFirstNameProperty.should != KABPersonLastNameProperty
  end
end

describe "kCFBooleanTrue" do
  it "can be retrieved" do
    KCFBooleanTrue.should == true
  end
end
