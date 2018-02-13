require 'spec_helper'

describe 'collections searches with an invalid place name' do
  include Capybara::DSL

  it 'unsupported place name is handled correctly' do
    VCR.use_cassette 'views/collection/invalid_place_name', :decode_compressed_response => true, :record => :once do
      visit collections_path
      select("Place Name", :from => 'spatial_type')
      fill_in("placeName", :with => 'dougopolis')
      click_button('Search')
      expect(page).to have_content("1 error prohibited this search from being executed:")
      expect(page).to have_content("Placename dougopolis cannot be located")
    end
  end
end