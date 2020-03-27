require 'spec_helper'

describe 'granule search form test'  do
  include Capybara::DSL

  it 'does not allow granule searches with empty UniqueID and ShortName and CollectionID' do
    VCR.use_cassette 'views/granule/allRequiredFormParamsEmpty', :record => :once, :decode_compressed_response => true do
      visit granules_path
      click_button('Search')
      expect(page).to have_content("3 errors prohibited this search from being executed:")
      expect(page).to have_content("Short name : A granule search requires the Collection ConceptID or the Collection ShortName or the Granule Unique Identifier")
      expect(page).to have_content("Collection concept ID : A granule search requires the Collection ConceptID or the Collection ShortName or the Granule Unique Identifier")
      expect(page).to have_content("Unique ID : A granule search requires the Collection ConceptID or the Collection ShortName or the Granule Unique Identifier")
    end
  end

  it 'does allows granule searches with only the ShortName parameter' do
    VCR.use_cassette 'views/granule/ShortNameParam', :record => :once, :decode_compressed_response => true do
      visit granules_path
      fill_in('shortName', :with => 'MOD02HKM')
      click_button('Search')
      expect(page).to have_content("Displaying 1 to 10 of 1024641")
    end
  end

  it 'does allows granule searches with only the CollectionConceptId parameter' do
    VCR.use_cassette 'views/granule/CollectionConceptIDParam', :record => :once, :decode_compressed_response => true do
      visit granules_path
      fill_in('parentIdentifier', :with => 'C203234490-LAADS')
      click_button('Search')
      expect(page).to have_content("Displaying 1 to 10 of 1023537")
    end
  end

  it 'does allows granule searches with only the UniqueID parameter' do
    VCR.use_cassette 'views/granule/UniqueIDParam', :record => :once, :decode_compressed_response => true do
      visit granules_path
      fill_in('uid', :with => 'G240103476-LAADS')
      click_button('Search')
      expect(page).to have_content("Displaying 1 to 1 of 1")
    end
  end

end
