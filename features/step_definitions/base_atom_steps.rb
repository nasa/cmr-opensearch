Given /^I have executed a (collection|granule) search with the following parameters:$/ do |resource, table|
  query_string = ''
  table.hashes.each do |hash|
    hash.each do |key, value|
      query_string += "&#{key}=#{URI.escape(value)}"
    end
  end
  visit("/#{resource}s.atom?#{query_string}")
  @response = page.body
  @response_doc = Nokogiri::XML(@response.to_str)
  @original_uri = page.current_url
end

Then /^I should see a valid (collection|granule) atom response$/ do |resource|
  assert @response_doc.xpath("/atom:feed", "atom" => "http://www.w3.org/2005/Atom").first
  assert @response_doc.xpath("/atom:feed/atom:updated", "atom" => "http://www.w3.org/2005/Atom").first
  assert @response_doc.xpath("/atom:feed/atom:id", "atom" => "http://www.w3.org/2005/Atom").first.to_str, "#{ENV['opensearch_url']}/collections.atom"
  assert_equal 'CMR', @response_doc.xpath("/atom:feed/atom:author/atom:name", "atom" => "http://www.w3.org/2005/Atom").first.to_str
  assert_equal ENV['contact'], @response_doc.xpath("/atom:feed/atom:author/atom:email", "atom" => "http://www.w3.org/2005/Atom").first.to_str
  assert_equal "CMR #{resource} metadata", @response_doc.xpath("/atom:feed/atom:title[@type='text']", "atom" => "http://www.w3.org/2005/Atom").first.to_str
  assert_equal 1, @response_doc.xpath("/atom:feed/os:totalResults", "atom" => "http://www.w3.org/2005/Atom", "os" => "http://a9.com/-/spec/opensearch/1.1/").size
  assert_equal 1, @response_doc.xpath("/atom:feed/atom:subtitle", "atom" => "http://www.w3.org/2005/Atom").size
  release_link = @response_doc.xpath("/atom:feed/atom:link[@rel='describedBy']", "atom" => 'http://www.w3.org/2005/Atom').first
  assert release_link
  assert_equal 'text/html', release_link[:type]
  assert_equal ENV['release_page'], release_link[:href]
  assert_equal "en-US", release_link[:hreflang]

  if resource == 'collection'
    osdd_link = @response_doc.xpath("/atom:feed/atom:link[@rel='search']", "atom" => 'http://www.w3.org/2005/Atom').first
    assert_equal "application/opensearchdescription+xml", osdd_link[:type]
    assert_equal "#{ENV['opensearch_url']}/granules/descriptor_document.xml", osdd_link[:href]
    assert_equal "en-US", osdd_link[:hreflang]

    self_link = @response_doc.xpath("/atom:feed/atom:link[@rel='self']", "atom" => 'http://www.w3.org/2005/Atom').first
    assert_equal "application/atom+xml", self_link[:type]
    assert_equal "en-US", self_link[:hreflang]
  end


end

Then /^I should see an open search query node in the results corresponding to:$/ do |table|
  query_node = @response_doc.xpath("/atom:feed/os:Query", "atom" => 'http://www.w3.org/2005/Atom', "os" => 'http://a9.com/-/spec/opensearch/1.1/').first
  table.hashes.each do |hash|
    hash.each do |key, value|
      assert_equal value, query_node[key.to_sym]
    end
  end
end

And /^result (\d+) should have a the following echo characteristics,$/ do |index, table|
  table.hashes.each do |hash|
    hash.each do |key, value|
      assert @response_doc.xpath("/atom:feed/atom:entry/echo:#{key}", "atom" => 'http://www.w3.org/2005/Atom', "echo" => 'http://www.echo.nasa.gov/esip').first.content, value
    end
  end
end

Then /^I should see (\d+) (result|results)$/ do |size, plural|
  assert_equal size.to_i, @response_doc.xpath("/atom:feed/atom:entry", "atom" => 'http://www.w3.org/2005/Atom').size.to_i
end

And /^result (\d+) should have a description of "(.*?)"$/ do |index, description|
  assert_equal description, @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/atom:summary[@type=\"text\"]", "atom" => 'http://www.w3.org/2005/Atom').first.content
end

And /^result (\d+) (should|should not) have a link to a granule search$/ do |index, should|
  link = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/atom:link[@title=\"Search for granules\"]", "atom" => 'http://www.w3.org/2005/Atom').first
  if should == 'should'
    assert link
    assert_equal 'application/atom+xml', link[:type]
    assert_equal 'search', link[:rel]
  else
    assert_nil link
  end

end

And /^result (\d+) (should|should not) have a link to a granule open search descriptor document$/ do |index, should|
  link = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/atom:link[@type=\"application/opensearchdescription+xml\"]", 'atom' => 'http://www.w3.org/2005/Atom').first
  if should == 'should'
    assert link
    assert_equal 'search', link[:rel]
  else
    assert_nil link
  end

end

Then /^result (\d+) (should|should not) have a (browse|data|metadata|documentation) link with href "(.*?)"$/ do |index, not_present, type, href|
  rel = 'icon' if type == "browse"
  rel = 'enclosure' if type == "data"
  rel = 'describedBy' if type == "documentation"
  rel = 'via' if type == "metadata"
  link = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/atom:link[@rel='#{rel}' and @href='#{href}']", "atom" => 'http://www.w3.org/2005/Atom').first

  if  not_present == "should not"
    assert_nil link
  else
    assert link
  end
end

Then /^I should see a total number of results value of (\d+)$/ do |total|
  assert total, @response_doc.xpath("/atom:feed/os:totalResults", "atom" => "http://www.w3.org/2005/Atom", "os" => "http://a9.com/-/spec/opensearch/1.1/").first.content
end

Then /^I should see a cursor value of (\d+)$/ do |cursor|
  assert cursor, @response_doc.xpath('/atom:feed/os:startIndex', "atom" => "http://www.w3.org/2005/Atom", "os" => "http://a9.com/-/spec/opensearch/1.1/").first.content
end

Then /^I should see a results per page value of (\d+)$/ do |per_page|
  assert per_page, @response_doc.xpath("/atom:feed/os:itemsPerPage", "atom" => "http://www.w3.org/2005/Atom", "os" => "http://a9.com/-/spec/opensearch/1.1/").first.content
end

And(/^result (\d+) should have a link to the full (collection|granule) metadata$/) do |index, resource|
  entry = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]", 'atom' => 'http://www.w3.org/2005/Atom').first
  guid = entry.xpath('atom:id', 'atom' => 'http://www.w3.org/2005/Atom').first.to_str
  guid.gsub!("#{ENV['opensearch_url']}/#{resource}s.atom?uid=", "")
  xpath = "atom:link[@href='#{ENV['public_catalog_rest_endpoint']}concepts/#{guid}.xml']"
  link = entry.xpath(xpath, 'atom' => 'http://www.w3.org/2005/Atom').first
  assert link
  assert_equal "via", link[:rel]
  assert_equal "Product metadata", link[:title]
  assert_equal "application/xml", link[:type]
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
  assert_equal number.to_i, @response_doc.xpath("errors/error").length
end

And(/^I should see the error "(.*?)"$/) do |text|
  success = false
  @response_doc.xpath("errors/error").each do |error|
    success = true if error.content == text
  end
  assert success
end

Then(/^I should see a valid error response$/) do
  assert @response_doc.xpath("errors")
end

Then(/^I should see a subtitle of "(.*?)"$/) do |subtitle|
  assert_equal subtitle, @response_doc.xpath("/atom:feed/atom:subtitle", "atom" => "http://www.w3.org/2005/Atom").first.to_str
end

Then(/^result (\d+) should have a title of "(.*?)"$/) do |index, value|
  id_element = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/atom:title", "atom" => "http://www.w3.org/2005/Atom").first

  assert id_element
  assert_equal value, id_element.content
end

Then(/^the result set (should|should not) have a link to this result$/) do |should|
  self_node = @response_doc.xpath("/atom:feed/atom:link[@rel=\"self\"]", "atom" => 'http://www.w3.org/2005/Atom').first
  if should == 'should'
    assert self_node
    # Verify that URI parameters match our original request
    assert_equal @original_uri, self_node[:href]
  else
    assert_nil self_node
  end
end

Then(/^the result set (should|should not) have a link to the (next|previous) result$/) do |should, direction|
  next_node = @response_doc.xpath("/atom:feed/atom:link[@rel=\"#{direction}\"]", "atom" => 'http://www.w3.org/2005/Atom').first
  if should == 'should'
    assert next_node
    new_query_hash = CGI::parse(next_node[:href].split('?')[1])
    query_hash = CGI::parse(URI.parse(@original_uri).query)
    # Verify that the cursor attribute in the href value is correctly incremented/decremented from our original request
    dif = 1 if direction == 'next'
    dif = -1 if direction == 'previous'
    dif = 2 if query_hash['cursor'][0].to_i == 0 and direction == 'next'
    assert_equal query_hash['cursor'][0].to_i + dif, new_query_hash['cursor'][0].to_i
    # Verify that the other parameters are unchanged
    new_query_hash.delete 'cursor'
    query_hash.delete 'cursor'
    assert_equal new_query_hash, query_hash
  else
    assert_nil next_node
  end
end

Then(/^the result set should have a link to the last result for a cursor of (\d+)$/) do |cursor|
  next_node = @response_doc.xpath("/atom:feed/atom:link[@rel=\"last\"]", "atom" => 'http://www.w3.org/2005/Atom').first

  assert next_node
  new_query_hash = CGI::parse(next_node[:href].split('?')[1])
  query_hash = CGI::parse(URI.parse(@original_uri).query)
  assert_equal cursor.to_i, new_query_hash['cursor'][0].to_i
  # Verify that the other parameters are unchanged
  new_query_hash.delete 'cursor'
  query_hash.delete 'cursor'
  assert_equal query_hash, new_query_hash

  new_query_hash.delete 'cursor'
  query_hash.delete 'cursor'
  assert_equal query_hash, new_query_hash

end

Then(/^the result set (should|should not) have a link to the first result$/) do |should|
  first_node = @response_doc.xpath("/atom:feed/atom:link[@rel=\"first\"]", "atom" => 'http://www.w3.org/2005/Atom').first
  if should == 'should'
    assert first_node
    # Verify that URI parameters match our original request
    new_query_hash = CGI::parse(first_node[:href].split('?')[1])
    query_hash = CGI::parse(URI.parse(@original_uri).query)
    new_query_hash.delete 'cursor'
    query_hash.delete 'cursor'
    assert_equal query_hash['cursor'][0].to_i, 0

    new_query_hash.delete 'cursor'
    query_hash.delete 'cursor'
    assert_equal new_query_hash, query_hash
  else
    assert_nil first_node
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
  d_element = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/dc:date", 'atom' => 'http://www.w3.org/2005/Atom', 'dc' => 'http://purl.org/dc/terms/').first
  assert d_element
  assert_equal extent, d_element.content
end

Then(/^result (\d+) should have no dublin core temporal extent$/) do |index|
  assert_nil @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/dc:date", 'atom' => 'http://www.w3.org/2005/Atom', 'dc' => 'http://purl.org/dc/terms/').first
end

And(/^result (\d+) should not have an open search time temporal extent$/) do |index|
  date_element = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/time:start", 'atom' => 'http://www.w3.org/2005/Atom', 'time' => 'http://a9.com/-/opensearch/extensions/time/1.0/').first
  assert_nil date_element
  date_element = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/time:end", 'atom' => 'http://www.w3.org/2005/Atom', 'time' => 'http://a9.com/-/opensearch/extensions/time/1.0/').first
  assert_nil date_element
end

Then /^I should not see a startPage element$/ do
  assert_nil @response_doc.xpath("/atom:feed/os:startPage", "atom" => "http://www.w3.org/2005/Atom", "os" => "http://a9.com/-/spec/opensearch/1.1/").first
end

Then /^I should not see an itemsPerPage element$/ do
  assert_nil @response_doc.xpath("/atom:feed/os:itemsPerPage", "atom" => "http://www.w3.org/2005/Atom", "os" => "http://a9.com/-/spec/opensearch/1.1/").first
end

And /^I should see a query element with the following characteristics,$/ do |table|
  query_element = @response_doc.xpath('/atom:feed/os:Query', 'atom' => 'http://www.w3.org/2005/Atom', 'os' => 'http://a9.com/-/spec/opensearch/1.1/').first
  assert query_element
  table.hashes.each do |hash|
    hash.each do |key, value|
      assert query_element[key] == value
    end
  end
end

And /^I should see a not supported HTTP response$/ do
  assert_equal page.status_code, 501
end

Then(/^result (\d+) should have a link href of '(.*?)' for the granule open search descriptor document$/) do |index, href|
  link = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/atom:link[@type=\"application/opensearchdescription+xml\"]", 'atom' => 'http://www.w3.org/2005/Atom').first
  assert_equal href, link[:href]
end

Then(/^result (\d+) (should|should not) have a geoss tag$/) do |index, should|
  geoss = @response_doc.xpath("/atom:feed/atom:entry[#{index.to_i}]/echo:is_geoss", 'atom' => 'http://www.w3.org/2005/Atom', 'echo' => 'http://www.echo.nasa.gov/esip').first
  if should == 'should'
    assert geoss
    assert_equal geoss.content, 'true'
  else
    assert_nil geoss
  end

end



