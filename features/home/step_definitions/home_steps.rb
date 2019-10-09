Given /^I am on the open search home page$/ do
  visit('/')
end

Then /^(?:|I )should see "([^\"]*)"?$/ do |content|
  expect(page.has_content?(content)).to be true
end

Then /^I should not see "([^"]*)"$/ do |content|
  expect(page.has_content?(content)).to be false
end

Then /^I should see the title "(.*?)"$/ do |title_text|
  page.should have_selector('h1', :text => title_text)
end

Then /^I should see the subtitle "(.*?)"$/ do |title_text|
  page.should have_selector('h2', :text => title_text)
end

Then /^I should see a page title reading "(.*?)"$/ do |title_text|
  #expect(first('title').native.text).to eq title_text
  page.has_title? title_text
end

And(/^I should see the current version of CMR/) do
  within('footer') do
     page.should have_link("Release: #{Rails.configuration.version.strip}", :href=>'https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information')
   end
end

And(/^I should see information regarding CMR OpenSearch release documentation$/) do
  assert page.has_content?('Release documentation can be found here')
  page.should have_link('here', :href=>'https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information')
end

And(/^I should see a link to the CMR OpenSearch release documentation$/) do
  within('footer') do
     page.should have_link("#{Rails.configuration.version.strip}", :href=>'https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information')
   end
end


