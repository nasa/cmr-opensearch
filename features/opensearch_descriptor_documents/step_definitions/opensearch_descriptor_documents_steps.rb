And /^I fill in the "([^"]*)" open search descriptor form with a client id of "([^"]*)"$/ do |form_class, client_id|
  within("form.#{form_class}") do
    fill_in 'clientId', :with => client_id
  end
end

And /^I fill in the "(.*?)" open search descriptor form with a short name of "([^"]*)"$/ do |form_class, short_name|
  within("form.#{form_class}") do
    fill_in 'shortName', :with => short_name
  end
end

And /^I fill in the "(.*?)" open search descriptor form with a version id of "([^"]*)"$/ do |form_class, version_id|
  within("form.#{form_class}") do
    fill_in 'versionId', :with => version_id
  end
end

And /^I fill in the "(.*?)" open search descriptor form with a data center of "([^"]*)"$/ do |form_class, data_center|
  within("form.#{form_class}") do
    fill_in 'dataCenter', :with => data_center
  end
end

And /^I click on "(.*?)" within the "(.*?)" form$/ do |button, form_class|
  within("form.#{form_class}") do
    click_button(button)
  end
end

Then /^I should see a collection open search descriptor document for client id "([^"]*)"$/ do |client_id|

  expected = <<-eos
  <?xml version="1.0" encoding="UTF-8" ?>
  <os:OpenSearchDescription
    xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
    xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom"
    xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/"
    xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/"
    xmlns:params="http://a9.com/-/spec/opensearch/extensions/parameters/1.0/"
    xmlns:referrer="http://www.opensearch.org/Specifications/OpenSearch/Extensions/Referrer/1.0"
    xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/"
    xmlns:atom="http://www.w3.org/2005/Atom" >
    <os:ShortName>CMR Collections</os:ShortName>
    <os:Description>NASA CMR Collection search using geo, time and parameter extensions</os:Description>
    <os:Contact>#{ENV['contact']}</os:Contact>
    <os:Url type="application/atom+xml" rel="collection" params:method="GET" template="#{ENV['opensearch_url']}/collections.atom?keyword={os:searchTerms?}&amp;instrument={echo:instrument?}&amp;satellite={eo:platform?}&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;geometry={geo:geometry?}&amp;placeName={geo:name?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;cursor={os:startPage?}&amp;numberOfResults={os:count?}&amp;offset={os:startIndex?}&amp;uid={geo:uid?}&amp;hasGranules={echo:hasGranules?}&amp;isCwic={echo:isCwic?}&amp;isGeoss={echo:isGeoss?}&amp;isCeos={echo:isCeos?}&amp;isEosdis={echo:isEosdis?}&amp;isFedeo={echo:isFedeo?}&amp;provider={echo:provider?}&amp;clientId=#{client_id}">
      <params:Parameter name="keyword" uiDisplay="Search terms" value="{os:searchTerms}" title="Inventory with terms expressed by these search terms" minimum="0">
        <atom:link rel="profile" href="http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html" title="This parameter follows the elastic search free text search implementations" />
      </params:Parameter>
      <params:Parameter name="instrument" uiDisplay="Instrument" value="{echo:instrument}" title="Inventory associated with a satellite instrument expressed by this short name" minimum="0" />
      <params:Parameter name="satellite" uiDisplay="Satellite" value="{eo:platform}" title="Inventory associated with a Satellite/platform expressed by this short name" minimum="0" />
      <params:Parameter name="boundingBox" uiDisplay="Bounding box" value="{geo:box}" title="Inventory with a spatial extent overlapping this bounding box" minimum="0" />
      <params:Parameter name="lat" uiDisplay="Latitude" value="{geo:lat}" title="Inventory with latitude in decimal degrees, must be used together with lon and radius" minimum="0" minInclusive="-90.0" maxInclusive="90.0" />
      <params:Parameter name="lon" uiDisplay="Longitude" value="{geo:lon}" title="Inventory with longitude in decimal degrees, must be used together with lat and radius" minimum="0" minInclusive="-180.0" maxInclusive="180.0" />
      <params:Parameter name="radius" uiDisplay="Radius" value="{geo:radius}" title="Inventory with the search radius in meters, must be used together with lat and lon" minimum="0" minInclusive="10" maxInclusive="6000000" />
      <params:Parameter name="geometry" uiDisplay="Geometry" value="{geo:geometry}" title="Inventory with a spatial extent overlapping this geometry" minimum="0">
        <atom:link rel="profile" href="http://www.opengis.net/wkt/LINESTRING" title="This service accepts WKT LineStrings" />
        <atom:link rel="profile" href="http://www.opengis.net/wkt/POINT" title="This service accepts WKT Points" />
        <atom:link rel="profile" href="http://www.opengis.net/wkt/POLYGON" title="This service accepts WKT Polygons" />
      </params:Parameter>
      <params:Parameter name="placeName" uiDisplay="Place name" value="{geo:name}" title="Inventory with a spatial location described by this name" minimum="0" />
      <params:Parameter name="startTime" uiDisplay="Start time" value="{time:start}" title="Inventory with a temporal extent containing this start time" minimum="0" />
      <params:Parameter name="endTime" uiDisplay="End time" value="{time:end}" title="Inventory with a temporal extent containing this end time" minimum="0" />
      <params:Parameter name="cursor" uiDisplay="Start page" value="{os:startPage}" title="Start page for the search result" minimum="0" />
      <params:Parameter name="numberOfResults" uiDisplay="Number of results" value="{os:count}" title="Maximum number of records in the search result" minimum="0" maxInclusive="2000" />
      <params:Parameter name="offset" uiDisplay="Start index" value="{os:startIndex}" title="0-based offset used to skip the specified number of results in the search result set" minimum="0" />
      <params:Parameter name="uid" uiDisplay="Unique identifier" value="{geo:uid}" title="Inventory associated with this unique ID" minimum="0" />
      <params:Parameter name="hasGranules" uiDisplay="Has granules" value="{echo:hasGranules}" title="Inventory with granules">
        <params:Option value="true" label="Yes" />
        <params:Option value="false" label="No" />
      </params:Parameter>
      <params:Parameter name="isCwic" uiDisplay="CWIC collection" value="{echo:isCwic}" title="Inventory related to CWIC">
        <params:Option value="true" label="Yes" />
      </params:Parameter>
      <params:Parameter name="isGeoss" uiDisplay="GEOSS collection" value="{echo:isGeoss}" title="Inventory related to GEOSS">
        <params:Option value="true" label="Yes" />
      </params:Parameter>
      <params:Parameter name="isCeos" uiDisplay="CEOS collection" value="{echo:isCeos}" title="Inventory related to CEOS">
        <params:Option value="true" label="Yes" />
      </params:Parameter>
      <params:Parameter name="isEosdis" uiDisplay="EOSDIS collection" value="{echo:isEosdis}" title="Inventory related to EOSDIS">
        <params:Option value="true" label="Yes" />
      </params:Parameter>
      <params:Parameter name="isFedeo" uiDisplay="FedEO collection" value="{echo:isFedeo}" title="Inventory related to FedEO">
        <params:Option value="true" label="Yes" />
      </params:Parameter>
      <params:Parameter name="provider" uiDisplay="Provider" value="{echo:provider}" title="Inventory associated with a provider" minimum="0" />
      <params:Parameter name="clientId" uiDisplay="Client identifier" value="{referrer:source}" title="Client identifier to be used for metrics" minimum="0" />
    </os:Url>
    <os:Url type="text/html" rel="collection" params:method="GET" template="#{ENV['opensearch_url']}/collections.html?keyword={os:searchTerms?}&amp;instrument={echo:instrument?}&amp;satellite={eo:platform?}&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;geometry={geo:geometry?}&amp;placeName={geo:name?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;cursor={os:startPage?}&amp;numberOfResults={os:count?}&amp;offset={os:startIndex?}&amp;uid={geo:uid?}&amp;hasGranules={echo:hasGranules?}&amp;isCwic={echo:isCwic?}&amp;isGeoss={echo:isGeoss?}&amp;isCeos={echo:isCeos?}&amp;isEosdis={echo:isEosdis?}&amp;isFedeo={echo:isFedeo?}&amp;provider={echo:provider?}&amp;clientId=#{client_id}">
      <params:Parameter name="keyword" uiDisplay="Search terms" value="{os:searchTerms}" title="Inventory with terms expressed by these search terms" minimum="0">
        <atom:link rel="profile" href="http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html" title="This parameter follows the elastic search free text search implementations" />
      </params:Parameter>
      <params:Parameter name="instrument" uiDisplay="Instrument" value="{echo:instrument}" title="Inventory associated with a satellite instrument expressed by this short name" minimum="0" />
      <params:Parameter name="satellite" uiDisplay="Satellite" value="{eo:platform}" title="Inventory associated with a Satellite/platform expressed by this short name" minimum="0" />
      <params:Parameter name="boundingBox" uiDisplay="Bounding box" value="{geo:box}" title="Inventory with a spatial extent overlapping this bounding box" minimum="0" />
      <params:Parameter name="lat" uiDisplay="Latitude" value="{geo:lat}" title="Inventory with latitude in decimal degrees, must be used together with lon and radius" minimum="0" minInclusive="-90.0" maxInclusive="90.0" />
      <params:Parameter name="lon" uiDisplay="Longitude" value="{geo:lon}" title="Inventory with longitude in decimal degrees, must be used together with lat and radius" minimum="0" minInclusive="-180.0" maxInclusive="180.0" />
      <params:Parameter name="radius" uiDisplay="Radius" value="{geo:radius}" title="Inventory with the search radius in meters, must be used together with lat and lon" minimum="0" minInclusive="10" maxInclusive="6000000" />
      <params:Parameter name="geometry" uiDisplay="Geometry" value="{geo:geometry}" title="Inventory with a spatial extent overlapping this geometry" minimum="0">
        <atom:link rel="profile" href="http://www.opengis.net/wkt/LINESTRING" title="This service accepts WKT LineStrings" />
        <atom:link rel="profile" href="http://www.opengis.net/wkt/POINT" title="This service accepts WKT Points" />
        <atom:link rel="profile" href="http://www.opengis.net/wkt/POLYGON" title="This service accepts WKT Polygons" />
      </params:Parameter>
      <params:Parameter name="placeName" uiDisplay="Place name" value="{geo:name}" title="Inventory with a spatial location described by this name" minimum="0" />
      <params:Parameter name="startTime" uiDisplay="Start time" value="{time:start}" title="Inventory with a temporal extent containing this start time" minimum="0" />
      <params:Parameter name="endTime" uiDisplay="End time" value="{time:end}" title="Inventory with a temporal extent containing this end time" minimum="0" />
      <params:Parameter name="cursor" uiDisplay="Start page" value="{os:startPage}" title="Start page for the search result" minimum="0" />
      <params:Parameter name="numberOfResults" uiDisplay="Number of results" value="{os:count}" title="Maximum number of records in the search result" minimum="0" maxInclusive="2000" />
      <params:Parameter name="offset" uiDisplay="Start index" value="{os:startIndex}" title="0-based offset used to skip the specified number of results in the search result set" minimum="0" />
      <params:Parameter name="uid" uiDisplay="Unique identifier" value="{geo:uid}" title="Inventory associated with this unique ID" minimum="0" />
      <params:Parameter name="hasGranules" uiDisplay="Has granules" value="{echo:hasGranules}" title="Inventory with granules">
        <params:Option value="true" label="Yes" />
        <params:Option value="false" label="No" />
      </params:Parameter>
      <params:Parameter name="isCwic" uiDisplay="CWIC collection" value="{echo:isCwic}" title="Inventory related to CWIC">
        <params:Option value="true" label="Yes" />
      </params:Parameter>
      <params:Parameter name="isGeoss" uiDisplay="GEOSS collection" value="{echo:isGeoss}" title="Inventory related to GEOSS">
        <params:Option value="true" label="Yes" />
      </params:Parameter>
      <params:Parameter name="isCeos" uiDisplay="CEOS collection" value="{echo:isCeos}" title="Inventory related to CEOS">
        <params:Option value="true" label="Yes" />
      </params:Parameter>
      <params:Parameter name="isEosdis" uiDisplay="EOSDIS collection" value="{echo:isEosdis}" title="Inventory related to EOSDIS">
        <params:Option value="true" label="Yes" />
      </params:Parameter>
      <params:Parameter name="isFedeo" uiDisplay="FedEO collection" value="{echo:isFedeo}" title="Inventory related to FedEO">
        <params:Option value="true" label="Yes" />
      </params:Parameter>
      <params:Parameter name="provider" uiDisplay="Provider" value="{echo:provider}" title="Inventory associated with a provider" minimum="0" />
      <params:Parameter name="clientId" uiDisplay="Client identifier" value="{referrer:source}" title="Client identifier to be used for metrics" minimum="0" />
    </os:Url>
    <os:Query role="example" searchTerms="Amazon River Basin Precipitation, 1972-1992" title="Sample search" />
    <os:Attribution>NASA CMR</os:Attribution>
    <os:SyndicationRight>open</os:SyndicationRight>
    <os:Tags>CMR NASA CWIC CEOS-OS-BP-V1.1/L3 ESIP OGC collection pageOffset=1 indexOffset=0</os:Tags>
  </os:OpenSearchDescription>
  eos

  expect(page.body.gsub(/\s+/, "")).to eq(expected.gsub(/\s+/, ""))
end

Then /^I should see a granule open search descriptor document for client id "([^"]*)"$/ do |client_id|
  expected = <<-eos
    <?xml version="1.0" encoding="UTF-8" ?>
    <os:OpenSearchDescription
      xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
      xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom"
      xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/"
      xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/"
      xmlns:params="http://a9.com/-/spec/opensearch/extensions/parameters/1.0/"
      xmlns:referrer="http://www.opensearch.org/Specifications/OpenSearch/Extensions/Referrer/1.0"
      xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/"
      xmlns:atom="http://www.w3.org/2005/Atom" >
      <os:ShortName>CMR Granules</os:ShortName>
      <os:Description>NASA CMR Granule search using geo, time and parameter extensions</os:Description>
      <os:Contact>#{ENV['contact']}</os:Contact>
      <os:Url type="application/atom+xml" rel="results" params:method="GET" template="#{ENV['opensearch_url']}/granules.atom?datasetId={echo:datasetId?}&amp;shortName={echo:shortName?}&amp;versionId={echo:versionId?}&amp;dataCenter={echo:dataCenter?}&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;geometry={geo:geometry?}&amp;placeName={geo:name?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;cursor={os:startPage?}&amp;numberOfResults={os:count?}&amp;offset={os:startIndex?}&amp;uid={geo:uid?}&amp;parentIdentifier={eo:parentIdentifier?}&amp;clientId=#{client_id}">
        <params:Parameter name="datasetId" uiDisplay="Collection identifier" value="{echo:datasetId}" title="Inventory associated with a dataset expressed as an ID" minimum="0" />
        <params:Parameter name="boundingBox" uiDisplay="Bounding box" value="{geo:box}" title="Inventory with a spatial extent overlapping this bounding box" minimum="0" />
        <params:Parameter name="lat" uiDisplay="Latitude" value="{geo:lat}" title="Inventory with latitude in decimal degrees, must be used together with lon and radius" minimum="0" minInclusive="-90.0" maxInclusive="90.0" />
        <params:Parameter name="lon" uiDisplay="Longitude" value="{geo:lon}" title="Inventory with longitude in decimal degrees, must be used together with lat and radius" minimum="0" minInclusive="-180.0" maxInclusive="180.0" />
        <params:Parameter name="radius" uiDisplay="Radius" value="{geo:radius}" title="Inventory with the search radius in meters, must be used together with lat and lon" minimum="0" minInclusive="10" maxInclusive="6000000" />
        <params:Parameter name="geometry" uiDisplay="Geometry" value="{geo:geometry}" title="Inventory with a spatial extent overlapping this geometry" minimum="0">
          <atom:link rel="profile" href="http://www.opengis.net/wkt/LINESTRING" title="This service accepts WKT LineStrings" />
          <atom:link rel="profile" href="http://www.opengis.net/wkt/POINT" title="This service accepts WKT Points" />
          <atom:link rel="profile" href="http://www.opengis.net/wkt/POLYGON" title="This service accepts WKT Polygons" />
        </params:Parameter>
        <params:Parameter name="placeName" uiDisplay="Place name" value="{geo:name}" title="Inventory with a spatial location described by this name" minimum="0" />
        <params:Parameter name="startTime" uiDisplay="Start time" value="{time:start}" title="Inventory with a temporal extent containing this start time" minimum="0" />
        <params:Parameter name="endTime" uiDisplay="End time" value="{time:end}" title="Inventory with a temporal extent containing this end time" minimum="0" />
        <params:Parameter name="cursor" uiDisplay="Start page" value="{os:startPage}" title="Start page for the search result" minimum="0" />
        <params:Parameter name="numberOfResults" uiDisplay="Number of results" value="{os:count}" title="Maximum number of records in the search result" minimum="0" maxInclusive="2000" />
        <params:Parameter name="offset" uiDisplay="Start index" value="{os:startIndex}" title="0-based offset used to skip the specified number of results in the search result set" minimum="0" />
        <params:Parameter name="uid" uiDisplay="Unique identifier identifier" value="{geo:uid}" title="Inventory associated with this unique ID" minimum="0" />
        <params:Parameter name="parentIdentifier" uiDisplay="CMR Collection concept identifier" value="{eo:parentIdentifier}" title="Inventory associated with a dataset expressed as a CMR concept ID" minimum="0" />
        <params:Parameter name="clientId" uiDisplay="Client identifier" value="{referrer:source}" title="Client identifier to be used for metrics" minimum="0" />
      </os:Url>
      <os:Url type="text/html" rel="results" params:method="GET" template="#{ENV['opensearch_url']}/granules.html?datasetId={echo:datasetId?}&amp;shortName={echo:shortName?}&amp;versionId={echo:versionId?}&amp;dataCenter={echo:dataCenter?}&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;geometry={geo:geometry?}&amp;placeName={geo:name?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;cursor={os:startPage?}&amp;numberOfResults={os:count?}&amp;offset={os:startIndex?}&amp;uid={geo:uid?}&amp;parentIdentifier={eo:parentIdentifier?}&amp;clientId=#{client_id}">
        <params:Parameter name="datasetId" uiDisplay="Collection identifier" value="{echo:datasetId}" title="Inventory associated with a dataset expressed as an ID" minimum="0" />
        <params:Parameter name="boundingBox" uiDisplay="Bounding box" value="{geo:box}" title="Inventory with a spatial extent overlapping this bounding box" minimum="0" />
        <params:Parameter name="lat" uiDisplay="Latitude" value="{geo:lat}" title="Inventory with latitude in decimal degrees, must be used together with lon and radius" minimum="0" minInclusive="-90.0" maxInclusive="90.0" />
        <params:Parameter name="lon" uiDisplay="Longitude" value="{geo:lon}" title="Inventory with longitude in decimal degrees, must be used together with lat and radius" minimum="0" minInclusive="-180.0" maxInclusive="180.0" />
        <params:Parameter name="radius" uiDisplay="Radius" value="{geo:radius}" title="Inventory with the search radius in meters, must be used together with lat and lon" minimum="0" minInclusive="10" maxInclusive="6000000" />
        <params:Parameter name="geometry" uiDisplay="Geometry" value="{geo:geometry}" title="Inventory with a spatial extent overlapping this geometry" minimum="0">
          <atom:link rel="profile" href="http://www.opengis.net/wkt/LINESTRING" title="This service accepts WKT LineStrings" />
          <atom:link rel="profile" href="http://www.opengis.net/wkt/POINT" title="This service accepts WKT Points" />
          <atom:link rel="profile" href="http://www.opengis.net/wkt/POLYGON" title="This service accepts WKT Polygons" />
        </params:Parameter>
        <params:Parameter name="placeName" uiDisplay="Place name" value="{geo:name}" title="Inventory with a spatial location described by this name" minimum="0" />
        <params:Parameter name="startTime" uiDisplay="Start time" value="{time:start}" title="Inventory with a temporal extent containing this start time" minimum="0" />
        <params:Parameter name="endTime" uiDisplay="End time" value="{time:end}" title="Inventory with a temporal extent containing this end time" minimum="0" />
        <params:Parameter name="cursor" uiDisplay="Start page" value="{os:startPage}" title="Start page for the search result" minimum="0" />
        <params:Parameter name="numberOfResults" uiDisplay="Number of results" value="{os:count}" title="Maximum number of records in the search result" minimum="0" maxInclusive="2000" />
        <params:Parameter name="offset" uiDisplay="Start index" value="{os:startIndex}" title="0-based offset used to skip the specified number of results in the search result set" minimum="0" />
        <params:Parameter name="uid" uiDisplay="Unique identifier identifier" value="{geo:uid}" title="Inventory associated with this unique ID" minimum="0" />
        <params:Parameter name="parentIdentifier" uiDisplay="CMR Collection concept identifier" value="{eo:parentIdentifier}" title="Inventory associated with a dataset expressed as a CMR concept ID" minimum="0" />
        <params:Parameter name="clientId" uiDisplay="Client identifier" value="{referrer:source}" title="Client identifier to be used for metrics" minimum="0" />
    </os:Url>
    <os:Query role="example"
      echo:shortName="MOD02QKM"
      echo:versionId="005"
      echo:dataCenter="LAADS"
      geo:box="-180.0,-90.0,180.0,90.0"
      time:start="2002-05-04T00:00:00Z"
      time:end="2009-05-04T00:00:00Z"
      title="Sample search" />
      <os:Attribution>NASA CMR</os:Attribution>
      <os:SyndicationRight>open</os:SyndicationRight>
      <os:Tags>CMR NASA CWIC CEOS-OS-BP-V1.1/L3 ESIP OGC granule pageOffset=1 indexOffset=0</os:Tags>
    </os:OpenSearchDescription>
  eos

  expect(page.body.gsub(/\s+/, "")).to eq(expected.gsub(/\s+/, ""))
end

Then /^I should see a granule open search descriptor document for client id "([^"]*)" and short name "([^"]*)"$/ do |client_id, short_name|
  expected = <<-eos
    <?xml version="1.0" encoding="UTF-8" ?>
    <os:OpenSearchDescription
      xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
      xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom"
      xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/"
      xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/"
      xmlns:params="http://a9.com/-/spec/opensearch/extensions/parameters/1.0/"
      xmlns:referrer="http://www.opensearch.org/Specifications/OpenSearch/Extensions/Referrer/1.0"
      xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/"
      xmlns:atom="http://www.w3.org/2005/Atom" >
      <os:ShortName>CMR Granules</os:ShortName>
      <os:Description>NASA CMR Granule search using geo, time and parameter extensions</os:Description>
      <os:Contact>#{ENV['contact']}</os:Contact>
      <os:Url type="application/atom+xml" rel="results" params:method="GET" template="#{ENV['opensearch_url']}/granules.atom?datasetId={echo:datasetId?}&amp;shortName=#{short_name}&amp;versionId={echo:versionId?}&amp;dataCenter={echo:dataCenter?}&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;geometry={geo:geometry?}&amp;placeName={geo:name?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;cursor={os:startPage?}&amp;numberOfResults={os:count?}&amp;offset={os:startIndex?}&amp;uid={geo:uid?}&amp;parentIdentifier={eo:parentIdentifier?}&amp;clientId=#{client_id}">
        <params:Parameter name="datasetId" uiDisplay="Collection identifier" value="{echo:datasetId}" title="Inventory associated with a dataset expressed as an ID" minimum="0" />
        <params:Parameter name="boundingBox" uiDisplay="Bounding box" value="{geo:box}" title="Inventory with a spatial extent overlapping this bounding box" minimum="0" />
        <params:Parameter name="lat" uiDisplay="Latitude" value="{geo:lat}" title="Inventory with latitude in decimal degrees, must be used together with lon and radius" minimum="0" minInclusive="-90.0" maxInclusive="90.0" />
        <params:Parameter name="lon" uiDisplay="Longitude" value="{geo:lon}" title="Inventory with longitude in decimal degrees, must be used together with lat and radius" minimum="0" minInclusive="-180.0" maxInclusive="180.0" />
        <params:Parameter name="radius" uiDisplay="Radius" value="{geo:radius}" title="Inventory with the search radius in meters, must be used together with lat and lon" minimum="0" minInclusive="10" maxInclusive="6000000" />
        <params:Parameter name="geometry" uiDisplay="Geometry" value="{geo:geometry}" title="Inventory with a spatial extent overlapping this geometry" minimum="0">
          <atom:link rel="profile" href="http://www.opengis.net/wkt/LINESTRING" title="This service accepts WKT LineStrings" />
          <atom:link rel="profile" href="http://www.opengis.net/wkt/POINT" title="This service accepts WKT Points" />
          <atom:link rel="profile" href="http://www.opengis.net/wkt/POLYGON" title="This service accepts WKT Polygons" />
        </params:Parameter>
        <params:Parameter name="placeName" uiDisplay="Place name" value="{geo:name}" title="Inventory with a spatial location described by this name" minimum="0" />
        <params:Parameter name="startTime" uiDisplay="Start time" value="{time:start}" title="Inventory with a temporal extent containing this start time" minimum="0" />
        <params:Parameter name="endTime" uiDisplay="End time" value="{time:end}" title="Inventory with a temporal extent containing this end time" minimum="0" />
        <params:Parameter name="cursor" uiDisplay="Start page" value="{os:startPage}" title="Start page for the search result" minimum="0" />
        <params:Parameter name="numberOfResults" uiDisplay="Number of results" value="{os:count}" title="Maximum number of records in the search result" minimum="0" maxInclusive="2000" />
        <params:Parameter name="offset" uiDisplay="Start index" value="{os:startIndex}" title="0-based offset used to skip the specified number of results in the search result set" minimum="0" />
        <params:Parameter name="uid" uiDisplay="Unique identifier identifier" value="{geo:uid}" title="Inventory associated with this unique ID" minimum="0" />
        <params:Parameter name="parentIdentifier" uiDisplay="CMR Collection concept identifier" value="{eo:parentIdentifier}" title="Inventory associated with a dataset expressed as a CMR concept ID" minimum="0" />
        <params:Parameter name="clientId" uiDisplay="Client identifier" value="{referrer:source}" title="Client identifier to be used for metrics" minimum="0" />
      </os:Url>
      <os:Url type="text/html" rel="results" params:method="GET" template="#{ENV['opensearch_url']}/granules.html?datasetId={echo:datasetId?}&amp;shortName=#{short_name}&amp;versionId={echo:versionId?}&amp;dataCenter={echo:dataCenter?}&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;geometry={geo:geometry?}&amp;placeName={geo:name?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;cursor={os:startPage?}&amp;numberOfResults={os:count?}&amp;offset={os:startIndex?}&amp;uid={geo:uid?}&amp;parentIdentifier={eo:parentIdentifier?}&amp;clientId=#{client_id}">
        <params:Parameter name="datasetId" uiDisplay="Collection identifier" value="{echo:datasetId}" title="Inventory associated with a dataset expressed as an ID" minimum="0" />
        <params:Parameter name="boundingBox" uiDisplay="Bounding box" value="{geo:box}" title="Inventory with a spatial extent overlapping this bounding box" minimum="0" />
        <params:Parameter name="lat" uiDisplay="Latitude" value="{geo:lat}" title="Inventory with latitude in decimal degrees, must be used together with lon and radius" minimum="0" minInclusive="-90.0" maxInclusive="90.0" />
        <params:Parameter name="lon" uiDisplay="Longitude" value="{geo:lon}" title="Inventory with longitude in decimal degrees, must be used together with lat and radius" minimum="0" minInclusive="-180.0" maxInclusive="180.0" />
        <params:Parameter name="radius" uiDisplay="Radius" value="{geo:radius}" title="Inventory with the search radius in meters, must be used together with lat and lon" minimum="0" minInclusive="10" maxInclusive="6000000" />
        <params:Parameter name="geometry" uiDisplay="Geometry" value="{geo:geometry}" title="Inventory with a spatial extent overlapping this geometry" minimum="0">
          <atom:link rel="profile" href="http://www.opengis.net/wkt/LINESTRING" title="This service accepts WKT LineStrings" />
          <atom:link rel="profile" href="http://www.opengis.net/wkt/POINT" title="This service accepts WKT Points" />
          <atom:link rel="profile" href="http://www.opengis.net/wkt/POLYGON" title="This service accepts WKT Polygons" />
        </params:Parameter>
        <params:Parameter name="placeName" uiDisplay="Place name" value="{geo:name}" title="Inventory with a spatial location described by this name" minimum="0" />
        <params:Parameter name="startTime" uiDisplay="Start time" value="{time:start}" title="Inventory with a temporal extent containing this start time" minimum="0" />
        <params:Parameter name="endTime" uiDisplay="End time" value="{time:end}" title="Inventory with a temporal extent containing this end time" minimum="0" />
        <params:Parameter name="cursor" uiDisplay="Start page" value="{os:startPage}" title="Start page for the search result" minimum="0" />
        <params:Parameter name="numberOfResults" uiDisplay="Number of results" value="{os:count}" title="Maximum number of records in the search result" minimum="0" maxInclusive="2000" />
        <params:Parameter name="offset" uiDisplay="Start index" value="{os:startIndex}" title="0-based offset used to skip the specified number of results in the search result set" minimum="0" />
        <params:Parameter name="uid" uiDisplay="Unique identifier identifier" value="{geo:uid}" title="Inventory associated with this unique ID" minimum="0" />
        <params:Parameter name="parentIdentifier" uiDisplay="CMR Collection concept identifier" value="{eo:parentIdentifier}" title="Inventory associated with a dataset expressed as a CMR concept ID" minimum="0" />
        <params:Parameter name="clientId" uiDisplay="Client identifier" value="{referrer:source}" title="Client identifier to be used for metrics" minimum="0" />
      </os:Url>
      <os:Query role="example"
        echo:shortName="MOD02QKM"
        echo:versionId="005"
        echo:dataCenter="LAADS"
        geo:box="-180.0,-90.0,180.0,90.0"
        time:start="2002-05-04T00:00:00Z"
        time:end="2009-05-04T00:00:00Z"
        title="Sample search" />
      <os:Attribution>NASA CMR</os:Attribution>
      <os:SyndicationRight>open</os:SyndicationRight>
      <os:Tags>CMR NASA CWIC CEOS-OS-BP-V1.1/L3 ESIP OGC granule pageOffset=1 indexOffset=0</os:Tags>
    </os:OpenSearchDescription>
  eos

  expect(page.body.gsub(/\s+/, "")).to eq(expected.gsub(/\s+/, ""))
end

Then /^I should see a granule open search descriptor document for client id "([^"]*)" short name "(.*?)" and version id "([^"]*)"$/ do |client_id, short_name, version_id|
  expected = <<-eos
    <?xml version="1.0" encoding="UTF-8" ?>
    <os:OpenSearchDescription
      xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
      xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom"
      xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/"
      xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/"
      xmlns:params="http://a9.com/-/spec/opensearch/extensions/parameters/1.0/"
      xmlns:referrer="http://www.opensearch.org/Specifications/OpenSearch/Extensions/Referrer/1.0"
      xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/"
      xmlns:atom="http://www.w3.org/2005/Atom">
      <os:ShortName>CMR Granules</os:ShortName>
      <os:Description>NASA CMR Granule search using geo, time and parameter extensions</os:Description>
      <os:Contact>#{ENV['contact']}</os:Contact>
      <os:Url type="application/atom+xml" rel="results" params:method="GET" template="#{ENV['opensearch_url']}/granules.atom?datasetId={echo:datasetId?}&amp;shortName=#{short_name}&amp;versionId=#{version_id}&amp;dataCenter={echo:dataCenter?}&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;geometry={geo:geometry?}&amp;placeName={geo:name?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;cursor={os:startPage?}&amp;numberOfResults={os:count?}&amp;offset={os:startIndex?}&amp;uid={geo:uid?}&amp;parentIdentifier={eo:parentIdentifier?}&amp;clientId=#{client_id}">
        <params:Parameter name="datasetId" uiDisplay="Collection identifier" value="{echo:datasetId}" title="Inventory associated with a dataset expressed as an ID" minimum="0" />
        <params:Parameter name="boundingBox" uiDisplay="Bounding box" value="{geo:box}" title="Inventory with a spatial extent overlapping this bounding box" minimum="0" />
        <params:Parameter name="lat" uiDisplay="Latitude" value="{geo:lat}" title="Inventory with latitude in decimal degrees, must be used together with lon and radius" minimum="0" minInclusive="-90.0" maxInclusive="90.0" />
        <params:Parameter name="lon" uiDisplay="Longitude" value="{geo:lon}" title="Inventory with longitude in decimal degrees, must be used together with lat and radius" minimum="0" minInclusive="-180.0" maxInclusive="180.0" />
        <params:Parameter name="radius" uiDisplay="Radius" value="{geo:radius}" title="Inventory with the search radius in meters, must be used together with lat and lon" minimum="0" minInclusive="10" maxInclusive="6000000" />
        <params:Parameter name="geometry" uiDisplay="Geometry" value="{geo:geometry}" title="Inventory with a spatial extent overlapping this geometry" minimum="0">
          <atom:link rel="profile" href="http://www.opengis.net/wkt/LINESTRING" title="This service accepts WKT LineStrings" />
          <atom:link rel="profile" href="http://www.opengis.net/wkt/POINT" title="This service accepts WKT Points" />
          <atom:link rel="profile" href="http://www.opengis.net/wkt/POLYGON" title="This service accepts WKT Polygons" />
        </params:Parameter>
        <params:Parameter name="placeName" uiDisplay="Place name" value="{geo:name}" title="Inventory with a spatial location described by this name" minimum="0" />
        <params:Parameter name="startTime" uiDisplay="Start time" value="{time:start}" title="Inventory with a temporal extent containing this start time" minimum="0" />
        <params:Parameter name="endTime" uiDisplay="End time" value="{time:end}" title="Inventory with a temporal extent containing this end time" minimum="0" />
        <params:Parameter name="cursor" uiDisplay="Start page" value="{os:startPage}" title="Start page for the search result" minimum="0" />
        <params:Parameter name="numberOfResults" uiDisplay="Number of results" value="{os:count}" title="Maximum number of records in the search result" minimum="0" maxInclusive="2000" />
        <params:Parameter name="offset" uiDisplay="Start index" value="{os:startIndex}" title="0-based offset used to skip the specified number of results in the search result set" minimum="0" />
        <params:Parameter name="uid" uiDisplay="Unique identifier identifier" value="{geo:uid}" title="Inventory associated with this unique ID" minimum="0" />
        <params:Parameter name="parentIdentifier" uiDisplay="CMR Collection concept identifier" value="{eo:parentIdentifier}" title="Inventory associated with a dataset expressed as a CMR concept ID" minimum="0" />
        <params:Parameter name="clientId" uiDisplay="Client identifier" value="{referrer:source}" title="Client identifier to be used for metrics" minimum="0" />
      </os:Url>
      <os:Url type="text/html" rel="results" params:method="GET" template="#{ENV['opensearch_url']}/granules.html?datasetId={echo:datasetId?}&amp;shortName=#{short_name}&amp;versionId=#{version_id}&amp;dataCenter={echo:dataCenter?}&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;geometry={geo:geometry?}&amp;placeName={geo:name?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;cursor={os:startPage?}&amp;numberOfResults={os:count?}&amp;offset={os:startIndex?}&amp;uid={geo:uid?}&amp;parentIdentifier={eo:parentIdentifier?}&amp;clientId=#{client_id}">
        <params:Parameter name="datasetId" uiDisplay="Collection identifier" value="{echo:datasetId}" title="Inventory associated with a dataset expressed as an ID" minimum="0" />
        <params:Parameter name="boundingBox" uiDisplay="Bounding box" value="{geo:box}" title="Inventory with a spatial extent overlapping this bounding box" minimum="0" />
        <params:Parameter name="lat" uiDisplay="Latitude" value="{geo:lat}" title="Inventory with latitude in decimal degrees, must be used together with lon and radius" minimum="0" minInclusive="-90.0" maxInclusive="90.0" />
        <params:Parameter name="lon" uiDisplay="Longitude" value="{geo:lon}" title="Inventory with longitude in decimal degrees, must be used together with lat and radius" minimum="0" minInclusive="-180.0" maxInclusive="180.0" />
        <params:Parameter name="radius" uiDisplay="Radius" value="{geo:radius}" title="Inventory with the search radius in meters, must be used together with lat and lon" minimum="0" minInclusive="10" maxInclusive="6000000" />
        <params:Parameter name="geometry" uiDisplay="Geometry" value="{geo:geometry}" title="Inventory with a spatial extent overlapping this geometry" minimum="0">
          <atom:link rel="profile" href="http://www.opengis.net/wkt/LINESTRING" title="This service accepts WKT LineStrings" />
          <atom:link rel="profile" href="http://www.opengis.net/wkt/POINT" title="This service accepts WKT Points" />
          <atom:link rel="profile" href="http://www.opengis.net/wkt/POLYGON" title="This service accepts WKT Polygons" />
        </params:Parameter>
        <params:Parameter name="placeName" uiDisplay="Place name" value="{geo:name}" title="Inventory with a spatial location described by this name" minimum="0" />
        <params:Parameter name="startTime" uiDisplay="Start time" value="{time:start}" title="Inventory with a temporal extent containing this start time" minimum="0" />
        <params:Parameter name="endTime" uiDisplay="End time" value="{time:end}" title="Inventory with a temporal extent containing this end time" minimum="0" />
        <params:Parameter name="cursor" uiDisplay="Start page" value="{os:startPage}" title="Start page for the search result" minimum="0" />
        <params:Parameter name="numberOfResults" uiDisplay="Number of results" value="{os:count}" title="Maximum number of records in the search result" minimum="0" maxInclusive="2000" />
        <params:Parameter name="offset" uiDisplay="Start index" value="{os:startIndex}" title="0-based offset used to skip the specified number of results in the search result set" minimum="0" />
        <params:Parameter name="uid" uiDisplay="Unique identifier identifier" value="{geo:uid}" title="Inventory associated with this unique ID" minimum="0" />
        <params:Parameter name="parentIdentifier" uiDisplay="CMR Collection concept identifier" value="{eo:parentIdentifier}" title="Inventory associated with a dataset expressed as a CMR concept ID" minimum="0" />
        <params:Parameter name="clientId" uiDisplay="Client identifier" value="{referrer:source}" title="Client identifier to be used for metrics" minimum="0" />
      </os:Url>
      <os:Query role="example"
        echo:shortName="MOD02QKM"
        echo:versionId="005"
        echo:dataCenter="LAADS"
        geo:box="-180.0,-90.0,180.0,90.0"
        time:start="2002-05-04T00:00:00Z"
        time:end="2009-05-04T00:00:00Z"
        title="Sample search" />
      <os:Attribution>NASA CMR</os:Attribution>
      <os:SyndicationRight>open</os:SyndicationRight>
      <os:Tags>CMR NASA CWIC CEOS-OS-BP-V1.1/L3 ESIP OGC granule pageOffset=1 indexOffset=0</os:Tags>
    </os:OpenSearchDescription>
  eos

  expect(page.body.gsub(/\s+/, "")).to eq(expected.gsub(/\s+/, ""))
end

Then /^I should see a granule open search descriptor document for client id "([^"]*)" short name "([^"]*)" version id "([^"]*)" and data center "([^"]*)"$/ do |client_id, short_name, version_id, data_center|
  expected = <<-eos
    <?xml version="1.0" encoding="UTF-8" ?>
    <os:OpenSearchDescription
      xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
      xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom"
      xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/"
      xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/"
      xmlns:params="http://a9.com/-/spec/opensearch/extensions/parameters/1.0/"
      xmlns:referrer="http://www.opensearch.org/Specifications/OpenSearch/Extensions/Referrer/1.0"
      xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/"
      xmlns:atom="http://www.w3.org/2005/Atom" >
      <os:ShortName>CMR Granules</os:ShortName>
      <os:Description>NASA CMR Granule search using geo, time and parameter extensions</os:Description>
      <os:Contact>#{ENV['contact']}</os:Contact>
      <os:Url type="application/atom+xml" rel="results" params:method="GET" template="#{ENV['opensearch_url']}/granules.atom?datasetId={echo:datasetId?}&amp;shortName=#{short_name}&amp;versionId=#{version_id}&amp;dataCenter=#{data_center}&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;geometry={geo:geometry?}&amp;placeName={geo:name?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;cursor={os:startPage?}&amp;numberOfResults={os:count?}&amp;offset={os:startIndex?}&amp;uid={geo:uid?}&amp;parentIdentifier={eo:parentIdentifier?}&amp;clientId=#{client_id}">
        <params:Parameter name="datasetId" uiDisplay="Collection identifier" value="{echo:datasetId}" title="Inventory associated with a dataset expressed as an ID" minimum="0" />
        <params:Parameter name="boundingBox" uiDisplay="Bounding box" value="{geo:box}" title="Inventory with a spatial extent overlapping this bounding box" minimum="0" />
        <params:Parameter name="lat" uiDisplay="Latitude" value="{geo:lat}" title="Inventory with latitude in decimal degrees, must be used together with lon and radius" minimum="0" minInclusive="-90.0" maxInclusive="90.0" />
        <params:Parameter name="lon" uiDisplay="Longitude" value="{geo:lon}" title="Inventory with longitude in decimal degrees, must be used together with lat and radius" minimum="0" minInclusive="-180.0" maxInclusive="180.0" />
        <params:Parameter name="radius" uiDisplay="Radius" value="{geo:radius}" title="Inventory with the search radius in meters, must be used together with lat and lon" minimum="0" minInclusive="10" maxInclusive="6000000" />
        <params:Parameter name="geometry" uiDisplay="Geometry" value="{geo:geometry}" title="Inventory with a spatial extent overlapping this geometry" minimum="0">
          <atom:link rel="profile" href="http://www.opengis.net/wkt/LINESTRING" title="This service accepts WKT LineStrings" />
          <atom:link rel="profile" href="http://www.opengis.net/wkt/POINT" title="This service accepts WKT Points" />
          <atom:link rel="profile" href="http://www.opengis.net/wkt/POLYGON" title="This service accepts WKT Polygons" />
        </params:Parameter>
        <params:Parameter name="placeName" uiDisplay="Place name" value="{geo:name}" title="Inventory with a spatial location described by this name" minimum="0" />
        <params:Parameter name="startTime" uiDisplay="Start time" value="{time:start}" title="Inventory with a temporal extent containing this start time" minimum="0" />
        <params:Parameter name="endTime" uiDisplay="End time" value="{time:end}" title="Inventory with a temporal extent containing this end time" minimum="0" />
        <params:Parameter name="cursor" uiDisplay="Start page" value="{os:startPage}" title="Start page for the search result" minimum="0" />
        <params:Parameter name="numberOfResults" uiDisplay="Number of results" value="{os:count}" title="Maximum number of records in the search result" minimum="0" maxInclusive="2000" />
        <params:Parameter name="offset" uiDisplay="Start index" value="{os:startIndex}" title="0-based offset used to skip the specified number of results in the search result set" minimum="0" />
        <params:Parameter name="uid" uiDisplay="Unique identifier identifier" value="{geo:uid}" title="Inventory associated with this unique ID" minimum="0" />
        <params:Parameter name="parentIdentifier" uiDisplay="CMR Collection concept identifier" value="{eo:parentIdentifier}" title="Inventory associated with a dataset expressed as a CMR concept ID" minimum="0" />
        <params:Parameter name="clientId" uiDisplay="Client identifier" value="{referrer:source}" title="Client identifier to be used for metrics" minimum="0" />
      </os:Url>
      <os:Url type="text/html" rel="results" params:method="GET" template="#{ENV['opensearch_url']}/granules.html?datasetId={echo:datasetId?}&amp;shortName=#{short_name}&amp;versionId=#{version_id}&amp;dataCenter=#{data_center}&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;geometry={geo:geometry?}&amp;placeName={geo:name?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;cursor={os:startPage?}&amp;numberOfResults={os:count?}&amp;offset={os:startIndex?}&amp;uid={geo:uid?}&amp;parentIdentifier={eo:parentIdentifier?}&amp;clientId=#{client_id}">
        <params:Parameter name="datasetId" uiDisplay="Collection identifier" value="{echo:datasetId}" title="Inventory associated with a dataset expressed as an ID" minimum="0" />
        <params:Parameter name="boundingBox" uiDisplay="Bounding box" value="{geo:box}" title="Inventory with a spatial extent overlapping this bounding box" minimum="0" />
        <params:Parameter name="lat" uiDisplay="Latitude" value="{geo:lat}" title="Inventory with latitude in decimal degrees, must be used together with lon and radius" minimum="0" minInclusive="-90.0" maxInclusive="90.0" />
        <params:Parameter name="lon" uiDisplay="Longitude" value="{geo:lon}" title="Inventory with longitude in decimal degrees, must be used together with lat and radius" minimum="0" minInclusive="-180.0" maxInclusive="180.0" />
        <params:Parameter name="radius" uiDisplay="Radius" value="{geo:radius}" title="Inventory with the search radius in meters, must be used together with lat and lon" minimum="0" minInclusive="10" maxInclusive="6000000" />
        <params:Parameter name="geometry" uiDisplay="Geometry" value="{geo:geometry}" title="Inventory with a spatial extent overlapping this geometry" minimum="0">
          <atom:link rel="profile" href="http://www.opengis.net/wkt/LINESTRING" title="This service accepts WKT LineStrings" />
          <atom:link rel="profile" href="http://www.opengis.net/wkt/POINT" title="This service accepts WKT Points" />
          <atom:link rel="profile" href="http://www.opengis.net/wkt/POLYGON" title="This service accepts WKT Polygons" />
        </params:Parameter>
        <params:Parameter name="placeName" uiDisplay="Place name" value="{geo:name}" title="Inventory with a spatial location described by this name" minimum="0" />
        <params:Parameter name="startTime" uiDisplay="Start time" value="{time:start}" title="Inventory with a temporal extent containing this start time" minimum="0" />
        <params:Parameter name="endTime" uiDisplay="End time" value="{time:end}" title="Inventory with a temporal extent containing this end time" minimum="0" />
        <params:Parameter name="cursor" uiDisplay="Start page" value="{os:startPage}" title="Start page for the search result" minimum="0" />
        <params:Parameter name="numberOfResults" uiDisplay="Number of results" value="{os:count}" title="Maximum number of records in the search result" minimum="0" maxInclusive="2000" />
        <params:Parameter name="offset" uiDisplay="Start index" value="{os:startIndex}" title="0-based offset used to skip the specified number of results in the search result set" minimum="0" />
        <params:Parameter name="uid" uiDisplay="Unique identifier identifier" value="{geo:uid}" title="Inventory associated with this unique ID" minimum="0" />
        <params:Parameter name="parentIdentifier" uiDisplay="CMR Collection concept identifier" value="{eo:parentIdentifier}" title="Inventory associated with a dataset expressed as a CMR concept ID" minimum="0" />
        <params:Parameter name="clientId" uiDisplay="Client identifier" value="{referrer:source}" title="Client identifier to be used for metrics" minimum="0" />
      </os:Url>
      <os:Query role="example"
        echo:shortName="MOD02QKM"
        echo:versionId="005"
        echo:dataCenter="LAADS"
        geo:box="-180.0,-90.0,180.0,90.0"
        time:start="2002-05-04T00:00:00Z"
        time:end="2009-05-04T00:00:00Z"
        title="Sample search" />
      <os:Attribution>NASA CMR</os:Attribution>
      <os:SyndicationRight>open</os:SyndicationRight>
      <os:Tags>CMR NASA CWIC CEOS-OS-BP-V1.1/L3 ESIP OGC granule pageOffset=1 indexOffset=0</os:Tags>
    </os:OpenSearchDescription>
  eos

  expect(page.body.gsub(/\s+/, "")).to eq(expected.gsub(/\s+/, ""))
end

Then /^I should see the error message "([^"]*)"$/ do |error|
  expect(page.has_content?(error)).to be true
end

And(/^I perform a dataset search using the open search descriptor template$/) do
  # Extract the template attribute from the url element corresponding to ATOM
  document = Nokogiri::XML(page.body)
  url_element = document.root.xpath('//os:Url[@type="application/atom+xml"]', 'os' => 'http://a9.com/-/spec/opensearch/1.1/').first
  datasets_url = url_element[:template].split('/')[4].split('?')[0]

  visit("/#{datasets_url}")
  response = page.body
  @response_doc = Nokogiri::XML(response.to_str)
end

And(/^I should see an attribution of "(.*?)"$/) do |text|
  document = Nokogiri::XML(page.body)
  attribution_element = document.root.xpath('//os:Attribution', 'os' => 'http://a9.com/-/spec/opensearch/1.1/').first
  expect(attribution_element).not_to be_nil
  expect(text).to eq(attribution_element.content)
end

And(/^I should see a syndication right of "(.*?)"$/) do |text|
  document = Nokogiri::XML(page.body)
  syndication_element = document.root.xpath('//os:SyndicationRight', 'os' => 'http://a9.com/-/spec/opensearch/1.1/').first
  expect(syndication_element).not_to be_nil
  expect(text).to eq(syndication_element.content)
end