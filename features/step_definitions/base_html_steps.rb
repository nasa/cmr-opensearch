And /^I look at the page$/ do
  puts page.body
end

And /^I search for (collection|granule)s$/ do |resource|
  within("p.#{resource}s") do
    click_link('Search')
  end
end

Then /^I should see the (collection|granule) search form$/ do |resource|
  page.should have_selector("form.#{resource}s")
  within("form.#{resource}s") do
    page.should have_selector("input#keyword") unless resource == "granule"
    page.should have_selector("input#instrument") unless resource == "granule"
    page.should have_selector("input#satellite") unless resource == "granule"

    page.should have_selector("input#startTime")
    page.should have_selector("input#endTime")

    page.should have_selector("input#shortName") unless resource == "collection"
    page.should have_selector("input#versionId") unless resource == "collection"
    page.should have_selector("input#dataCenter") unless resource == "collection"

    page.should have_selector("select#spatial_type")

    page.should have_xpath("//select/option[@value='bbox']")
    page.should have_xpath("//select/option[@value='geometry']")
    page.should have_xpath("//select/option[@value='placename']")

    page.should have_selector("input#boundingBox")
    page.should have_selector("input#geometry")
    page.should have_selector("input#placeName")
    page.should have_selector("input#uid")
    page.should have_selector("input#numberOfResults")
    page.should have_selector("input#cursor")

    page.should have_button('Search')
  end
end

Then /^I should see the (collection|granule) results$/ do |resource|
  page.should have_selector('ul.results')
  expect(all('li.result').length).to eq(10)

  within('section.navigation > section#metrics') do
    page.should have_content 'Displaying 1 to 10 of'
  end
  expect(all('a > i.fa-chevron-circle-right').size).to eq(2)
end

Given /^I am on the open search (collection|granule) search page$/ do |resource|
  visit("/#{resource}s")
end

Then /^I click on "(.*?)"$/ do |button|
  within("form") do
    click_button(button)
  end
end
Then /^I click on the link "(.*?)"$/ do |button|
  click_link(button)
end


Then /^I should see (\d+) (collection|granule) (result|results)$/ do |number, resource, plural|
  save_and_open_page
  expect(all('li.result').length).to eq(number.to_i)
end

And /^(collection|granule) result (\d+) should have a the following echo characteristics,$/ do |resource, index, table|
  table.hashes.map do |hash|
    characteristic = hash['characteristic']
    value = hash['value']
    within(:xpath, "//ul[@class='results']/li[#{index}]") do
      find("span.#{characteristic}").should have_content(value) unless characteristic == 'granule_ur'
      find('h3').should have_content(value) if characteristic == 'granule_ur'
    end
  end
end

And /^(collection|granule) result (\d+) should have a description of "(.*?)"$/ do |resource, index, description|
  within(:xpath, "//ul[@class='results']/li[#{index}]") do
    find('p.content-description').should have_content(description)
  end
end

Given /^I have executed a html (collection|granule) search with the following parameters:$/ do |resource, table|
  visit("/#{resource}s")
  Capybara.ignore_hidden_elements = false
  table.hashes.map do |hash|
    input = hash["input"]
    value = hash["value"]
    if input == 'spatial_type' or input == 'hasGranules' or input == 'isCwic' or input == 'isGeoss'
      select(value, :from => input)
    else
      fill_in(input, :with => value)
    end
  end
  Capybara.ignore_hidden_elements = true
  click_button("Search")
end

And /^I should see the hidden input "(.*?)" with a value of "(.*?)"$/ do |id, value|
  success = false
  all(:xpath, "//input[@type='hidden']", visible: false).each do |element|
    success = true if element[:id] == id and element[:value] == value
  end
  expect(success).to be true
end

And /^(dataset|granule) result (\d+) (should|should not) have a (browse|data|metadata|documentation) link with href "(.*?)"$/ do |resource, index, not_present, type, href|
  success = false
  within(:xpath, "//ul[@class='results']/li[#{index}]") do
    within('ul.optional-links') do
      all('li > a').each do |a|
        success = true if a[:href] == href #and a.has_content(type_text)
      end
    end
  end
  expect(success).to be true if not_present == 'should'
  expect(success).to be false if not_present == 'should not'
end

And(/^I should see (\d+) error (message|messages)$/) do |number, plural|
  within('div.error_explanation') do
    expect(all('li').length).to eq(number.to_i)
  end
end

And(/^I execute a html (collection|granule) search using the unique id associated with result number (\d+)$/) do |resource, index|
  uid = nil
  within(:xpath, "//ul[@class='results']/li[#{index}]") do
    uid = find("span.uid").text
  end
  all("input").each do |element|
    if resource == 'collection'
      fill_in(element[:name], :with => "") if %w(placeName keyword instrument satellite startTime endTime boundingBox geometry placeName numberOfResults cursor shortName versionId dataCenter dataset_id uid).include? element[:name]
    else
      fill_in(element[:name], :with => "") if %w(placeName startTime endTime boundingBox geometry placeName numberOfResults cursor shortName versionId dataCenter dataset_id uid).include? element[:name]
    end
  end
  fill_in("uid", :with => uid)
  click_button("Search")
end

When(/^I search for granules in result (\d+)$/) do |index|
  within(:xpath, "//ul[@class='results']/li[#{index}]") do
    click_link('Search this collection...')
  end
end

Then(/^I should see the following inputs:$/) do |table|
  table.hashes.map do |hash|
    input = hash["input"]
    value = hash["value"]
    within(:xpath, "//form") do
      if input == 'spatial_type' or input == 'hasGranules' or input == 'isCwic' or input == 'isGeoss'
        expect(find("select##{input}")[:value]).to eq(value)
      else
        expect(find("input##{input}")[:value]).to eq(value)
      end
    end
  end
end

And(/^I fill in "(.*?)" for "(.*?)"$/) do |number, field|
  fill_in(field, :with => number)
end

And(/^I select collections that (do|do not) have granules$/) do |choice|
  if choice == 'do'
    find("option[value='true']").click
  else
    find("option[value='false']").click
  end
end

When(/^I navigate (forward|backward)$/) do |direction|
  if direction == 'forward'
    id = 'top_next'
  else
    id = 'top_previous' if direction == 'backward'
  end
  click_link(id)
end

Then(/^I should see a spatial extent of "(.*?)"$/) do |value|
  within('div.group-meta') do
    find('span.spatial-extent').should have_content(value)
  end
end

When(/^I should see a temporal start of "(.*?)"$/) do |value|
  within('time.temporal-extent') do
    find('span.temporal-extent-start').should have_content(value)
  end
end

Then(/^I should see a temporal end of "(.*?)"$/) do |value|
  within('time.temporal-extent') do
    find('span.temporal-extent-end').should have_content(value)
  end
end

Then(/^I (should|should not) see a granule search link within (collection|granule) (\d+)$/) do |should, concept, index|
  within(:xpath, "//ul[@class='results']/li[#{index}]") do
    if should == 'should'
      page.should have_link('Search this collection...')
    else
      page.should have_no_link('Search this collection...')
    end
  end
end

Then(/^I (should|should not) see "(.*?)" within (collection|granule) (\d+)$/) do |should, text, concept, index|
  within(:xpath, "//ul[@class='results']/li[#{index}]") do
    if should == 'should'
      page.should have_content(text)
    else
      page.should have_no_content(text)
    end
  end
end

