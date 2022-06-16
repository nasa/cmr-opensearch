Given /^I have executed a (collection|granule) search with the following parameters:$/ do |resource, table|
  query_string = ''
  table.hashes.each do |hash|
    query_string += URI.encode_www_form(hash) + '&'
  end
  query_string = query_string.chop

  visit("/#{resource}s.atom?#{query_string}")
  @response = page.body
  @response_doc = Nokogiri::XML(@response.to_str)
  @original_uri = page.current_url
end

Then /^I should see a valid (collection|granule) atom response$/ do |resource|
  expect(@response_doc.xpath("/atom:feed", "atom" => "http://www.w3.org/2005/Atom").first).to be
  expect(@response_doc.xpath("/atom:feed/atom:updated", "atom" => "http://www.w3.org/2005/Atom").first).to be
  expect(@response_doc.xpath("/atom:feed/atom:id", "atom" => "http://www.w3.org/2005/Atom").first.to_str).to eq("#{ENV['opensearch_url']}/#{resource}s.atom")
  expect(@response_doc.xpath("/atom:feed/atom:author/atom:name", "atom" => "http://www.w3.org/2005/Atom").first.to_str).to eq('CMR')
  expect(@response_doc.xpath("/atom:feed/atom:author/atom:email", "atom" => "http://www.w3.org/2005/Atom").first.to_str).to eq(ENV['contact'])
  expect(@response_doc.xpath("/atom:feed/atom:title[@type='text']", "atom" => "http://www.w3.org/2005/Atom").first.to_str).to eq("CMR #{resource} metadata")
  expect(@response_doc.xpath("/atom:feed/os:totalResults", "atom" => "http://www.w3.org/2005/Atom", "os" => "http://a9.com/-/spec/opensearch/1.1/").size).to eq(1)
  expect(@response_doc.xpath("/atom:feed/atom:subtitle", "atom" => "http://www.w3.org/2005/Atom").size).to eq(1)
  release_link = @response_doc.xpath("/atom:feed/atom:link[@rel='describedBy']", "atom" => 'http://www.w3.org/2005/Atom').first
  expect(release_link).to be
  expect(release_link[:type]).to eq('text/html')
  expect(release_link[:href]).to eq(ENV['release_page'])
  expect(release_link[:hreflang]).to eq('en-US')
  if resource == 'collection'
    osdd_link = @response_doc.xpath("/atom:feed/atom:link[@rel='search']", "atom" => 'http://www.w3.org/2005/Atom').first
    expect(osdd_link[:type]).to eq('application/opensearchdescription+xml')
    expect(osdd_link[:href]).to eq("#{ENV['opensearch_url']}/granules/descriptor_document.xml")
    expect(osdd_link[:hreflang]).to eq('en-US')
    self_link = @response_doc.xpath("/atom:feed/atom:link[@rel='self']", "atom" => 'http://www.w3.org/2005/Atom').first
    expect(self_link[:type]).to eq('application/atom+xml')
    expect(self_link[:hreflang]).to eq('en-US')
  end


end

Then /^I should see an open search query node in the results corresponding to:$/ do |table|
  query_node = @response_doc.xpath("/atom:feed/os:Query", "atom" => 'http://www.w3.org/2005/Atom', "os" => 'http://a9.com/-/spec/opensearch/1.1/').first
  table.hashes.each do |hash|
    hash.each do |key, value|
      expect(value).to eq(query_node[key.to_sym])
    end
  end
end

And /^result (\d+) should have a the following echo characteristics,$/ do |index, table|
  table.hashes.each do |hash|
    hash.each do |key, value|
      expect(@response_doc.xpath("/atom:feed/atom:entry/echo:#{key}", "atom" => 'http://www.w3.org/2005/Atom', "echo" => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom').first.content).to eq(value)
    end
  end
end

Then /^I should see (\d+) (result|results)$/ do |size, plural|
  expect(@response_doc.xpath("/atom:feed/atom:entry", "atom" => 'http://www.w3.org/2005/Atom').size.to_i).to eq(size.to_i)
end

And /^result (\d+) should have a description of "(.*?)"$/ do |index, description|
  expect(@response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/atom:summary[@type=\"text\"]", "atom" => 'http://www.w3.org/2005/Atom').first.content).to eq(description)
end

And /^result (\d+) (should|should not) have a link to a granule search$/ do |index, should|
  link = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/atom:link[@title=\"Search for granules\"]", "atom" => 'http://www.w3.org/2005/Atom').first
  if should == 'should'
    expect(link).to be
    expect(link[:type]).to eq('application/atom+xml')
    expect(link[:rel]).to eq('search')
  else
    expect(link).to be nil
  end

end

And /^result (\d+) (should|should not) have a link to a granule open search descriptor document$/ do |index, should|
  link = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/atom:link[@type=\"application/opensearchdescription+xml\"]", 'atom' => 'http://www.w3.org/2005/Atom').first
  if should == 'should'
    expect(link).to be
    expect(link[:rel]).to eq('search')
  else
    expect(link).to be nil
  end

end

Then /^result (\d+) (should|should not) have a (browse|data|metadata|documentation) link with href "(.*?)"$/ do |index, not_present, type, href|
  rel = 'icon' if type == "browse"
  rel = 'enclosure' if type == "data"
  rel = 'describedBy' if type == "documentation"
  rel = 'via' if type == "metadata"
  link = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/atom:link[@rel='#{rel}' and @href='#{href}']", "atom" => 'http://www.w3.org/2005/Atom').first

  if  not_present == "should not"
    expect(link).to be nil
  else
    expect(link).to be
  end
end

Then /^I should see a total number of results value of (\d+)$/ do |total|
  expect(@response_doc.xpath("/atom:feed/os:totalResults", "atom" => "http://www.w3.org/2005/Atom", "os" => "http://a9.com/-/spec/opensearch/1.1/").first.content).to eq(total.to_s)
end

Then /^I should see a startIndex value of (\d+)$/ do |cursor|
  expect(@response_doc.xpath('/atom:feed/os:startIndex', "atom" => "http://www.w3.org/2005/Atom", "os" => "http://a9.com/-/spec/opensearch/1.1/").first.content).to eq(cursor.to_s)
end

Then /^I should see a results per page value of (\d+)$/ do |per_page|
  expect(@response_doc.xpath("/atom:feed/os:itemsPerPage", "atom" => "http://www.w3.org/2005/Atom", "os" => "http://a9.com/-/spec/opensearch/1.1/").first.content).to eq(per_page.to_s)
end

And(/^result (\d+) should have a link to the full (collection|granule) metadata$/) do |index, resource|
  entry = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]", 'atom' => 'http://www.w3.org/2005/Atom').first
  guid = entry.xpath('atom:id', 'atom' => 'http://www.w3.org/2005/Atom').first.to_str
  guid.gsub!("#{ENV['opensearch_url']}/#{resource}s.atom?uid=", "")
  xpath = "atom:link[@href='#{ENV['public_catalog_rest_endpoint']}concepts/#{guid}.xml']"
  link = entry.xpath(xpath, 'atom' => 'http://www.w3.org/2005/Atom').first
  expect(link).to be
  expect(link[:rel]).to eq('via')
  expect(link[:title]).to eq('Product metadata')
  expect(link[:type]).to eq('application/xml')
end

And(/^I execute a (collection|granule) search using the unique id associated with result number (\d+)$/) do |resource, index|
  entry = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]", 'atom' => 'http://www.w3.org/2005/Atom').first
  guid = entry.xpath('atom:id', 'atom' => 'http://www.w3.org/2005/Atom').first.to_str
  guid.gsub!("#{ENV['opensearch_url']}/#{resource}s.atom?uid=", "")
  visit("/#{resource}s.atom?uid=#{guid}")
  response = page.body
  @response_doc = Nokogiri::XML(response.to_str)
end

And(/^I should see (\d+) (error|errors)$/) do |number, plural|
  expect(@response_doc.xpath("errors/error").length).to eq(number.to_i)
end

And(/^I should see the error "(.*?)"$/) do |text|
  success = false
  @response_doc.xpath("errors/error").each do |error|
    success = true if error.content == text
  end
  expect(success).to be
end

Then(/^I should see a valid error response$/) do
  expect(@response_doc.xpath("errors")).to be
end

Then(/^I should see a subtitle of "(.*?)"$/) do |subtitle|
  expect(@response_doc.xpath("/atom:feed/atom:subtitle", "atom" => "http://www.w3.org/2005/Atom").first.to_str).to eq(subtitle)
end

Then(/^result (\d+) should have a title of "(.*?)"$/) do |index, value|
  id_element = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/atom:title", "atom" => "http://www.w3.org/2005/Atom").first
  expect(id_element).to be
  expect(id_element.content).to eq(value)
end

Then(/^the result set (should|should not) have a link to this result$/) do |should|
  self_node = @response_doc.xpath("/atom:feed/atom:link[@rel=\"self\"]", "atom" => 'http://www.w3.org/2005/Atom').first
  if should == 'should'
    expect(self_node).to be
    # Verify that URI parameters match our original request
    expect(self_node[:href]).to eq(@original_uri)
  else
    expect(self_node).to be nil
  end
end

Then(/^the result set (should|should not) have a link to the (next|previous) result$/) do |should, direction|
  next_node = @response_doc.xpath("/atom:feed/atom:link[@rel=\"#{direction}\"]", "atom" => 'http://www.w3.org/2005/Atom').first
  if should == 'should'
    expect(next_node).to be
    new_query_hash = CGI::parse(next_node[:href].split('?')[1])
    query_hash = CGI::parse(URI.parse(@original_uri).query)
    # Verify that the cursor attribute in the href value is correctly incremented/decremented from our original request
    dif = 1 if direction == 'next'
    dif = -1 if direction == 'previous'
    dif = 2 if query_hash['cursor'][0].to_i == 0 and direction == 'next'
    expect(query_hash['cursor'][0].to_i + dif).to eq(new_query_hash['cursor'][0].to_i)
    # Verify that the other parameters are unchanged
    new_query_hash.delete 'cursor'
    query_hash.delete 'cursor'
    expect(new_query_hash).to eq(query_hash)
  else
    expect(next_node).to be nil
  end
end

Then(/^the result set should have a link to the last result for a cursor of (\d+)$/) do |cursor|
  next_node = @response_doc.xpath("/atom:feed/atom:link[@rel=\"last\"]", "atom" => 'http://www.w3.org/2005/Atom').first
  expect(next_node).to be
  new_query_hash = CGI::parse(next_node[:href].split('?')[1])
  query_hash = CGI::parse(URI.parse(@original_uri).query)
  expect(cursor.to_i).to eq(new_query_hash['cursor'][0].to_i)
  # Verify that the other parameters are unchanged
  new_query_hash.delete 'cursor'
  query_hash.delete 'cursor'
  expect(query_hash).to eq(new_query_hash)
  new_query_hash.delete 'cursor'
  query_hash.delete 'cursor'
  expect(query_hash).to eq(new_query_hash)

end

Then(/^the result set (should|should not) have a link to the first result$/) do |should|
  first_node = @response_doc.xpath("/atom:feed/atom:link[@rel=\"first\"]", "atom" => 'http://www.w3.org/2005/Atom').first
  if should == 'should'
    expect(first_node).to be
    # Verify that URI parameters match our original request
    new_query_hash = CGI::parse(first_node[:href].split('?')[1])
    query_hash = CGI::parse(URI.parse(@original_uri).query)
    new_query_hash.delete 'cursor'
    query_hash.delete 'cursor'
    expect(query_hash['cursor'][0].to_i).to eq 0

    new_query_hash.delete 'cursor'
    query_hash.delete 'cursor'
    expect(new_query_hash).to eq(query_hash)
  else
    expect(first_node).to be nil
  end
end

When(/^I navigate to the (next|previous) result$/) do |direction|
  link = @response_doc.xpath("/atom:feed/atom:link[@rel=\"#{direction}\"]", "atom" => 'http://www.w3.org/2005/Atom').first[:href]
  visit(link)
  response = page.body
  @response_doc = Nokogiri::XML(response.to_str)
  @original_uri = page.current_url
end

Then(/^result (\d+) should have a dublin core temporal extent of "(.*?)"$/) do |index, extent|
  d_element = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/dc:date", 'atom' => 'http://www.w3.org/2005/Atom', 'dc' => 'http://purl.org/dc/elements/1.1/').first
  expect(d_element).to be
  expect(d_element.content).to eq(extent)
end

Then(/^result (\d+) should have no dublin core temporal extent$/) do |index|
  expect(@response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/dc:date", 'atom' => 'http://www.w3.org/2005/Atom', 'dc' => 'http://purl.org/dc/elements/1.1/').first).to be nil
end

And(/^result (\d+) should not have an open search time temporal extent$/) do |index|
  date_element = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/time:start", 'atom' => 'http://www.w3.org/2005/Atom', 'time' => 'http://a9.com/-/opensearch/extensions/time/1.0/').first
  expect(date_element).to be nil
  date_element = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/time:end", 'atom' => 'http://www.w3.org/2005/Atom', 'time' => 'http://a9.com/-/opensearch/extensions/time/1.0/').first
  expect(date_element).to be nil
end

Then /^I should not see a startPage element$/ do
  expect(@response_doc.xpath("/atom:feed/os:startPage", "atom" => "http://www.w3.org/2005/Atom", "os" => "http://a9.com/-/spec/opensearch/1.1/").first).to be nil
end

Then /^I should not see an itemsPerPage element$/ do
  expect(@response_doc.xpath("/atom:feed/os:itemsPerPage", "atom" => "http://www.w3.org/2005/Atom", "os" => "http://a9.com/-/spec/opensearch/1.1/").first).to be nil
end

And /^I should see a query element with the following characteristics,$/ do |table|
  query_element = @response_doc.xpath('/atom:feed/os:Query', 'atom' => 'http://www.w3.org/2005/Atom', 'os' => 'http://a9.com/-/spec/opensearch/1.1/').first
  expect(query_element).to be
  table.hashes.each do |hash|
    hash.each do |key, value|
      expect(query_element[key]).to eq(value)
    end
  end
end

And /^I should see a not supported HTTP response$/ do
  expect(page.status_code).to eq(501)
end

Then(/^result (\d+) should have a link href of '(.*?)' for the granule open search descriptor document$/) do |index, href|
  link = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/atom:link[@type=\"application/opensearchdescription+xml\"]", 'atom' => 'http://www.w3.org/2005/Atom').first
  expect(link[:href]).to eq(href)
end

Then(/^result (\d+) (should|should not) have a geoss tag$/) do |index, should|
  geoss = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/echo:is_geoss", 'atom' => 'http://www.w3.org/2005/Atom', 'echo' => 'https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom').first
  if should == 'should'
    expect(geoss).to be
    expect(geoss.content).to eq('true')
  else
    expect(geoss).to be nil
  end

end
