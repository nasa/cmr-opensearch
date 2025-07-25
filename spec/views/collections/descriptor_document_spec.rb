require 'spec_helper'

describe 'collections/descriptor_document' do
  it 'is possible to create a collection open search descriptor document with a valid client id' do
    stub_client_id = stub_model(ClientId)
    stub_client_id.clientId = 'foo'
    assign(:client_id_model, stub_client_id)
    render
    expect(rendered).to include("template=\"#{ENV['opensearch_url']}/collections.atom?keyword={os:searchTerms?}&amp;instrument={echo:instrument?}&amp;satellite={eo:platform?}&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;geometry={geo:geometry?}&amp;placeName={geo:name?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;cursor={os:startPage?}&amp;numberOfResults={os:count?}&amp;offset={os:startIndex?}&amp;uid={geo:uid?}&amp;hasGranules={echo:hasGranules?}&amp;isCwic={echo:isCwic?}&amp;isGeoss={echo:isGeoss?}&amp;isCeos={echo:isCeos?}&amp;isEosdis={echo:isEosdis?}&amp;isFedeo={echo:isFedeo?}&amp;provider={echo:provider?}&amp;clientId=foo")
    expect(rendered).to include("template=\"#{ENV['opensearch_url']}/collections.html?keyword={os:searchTerms?}&amp;instrument={echo:instrument?}&amp;satellite={eo:platform?}&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;geometry={geo:geometry?}&amp;placeName={geo:name?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;cursor={os:startPage?}&amp;numberOfResults={os:count?}&amp;offset={os:startIndex?}&amp;uid={geo:uid?}&amp;hasGranules={echo:hasGranules?}&amp;isCwic={echo:isCwic?}&amp;isGeoss={echo:isGeoss?}&amp;isCeos={echo:isCeos?}&amp;isEosdis={echo:isEosdis?}&amp;isFedeo={echo:isFedeo?}&amp;provider={echo:provider?}&amp;clientId=foo")
  end

  it "is comformant with draft 2 of the open search parameter extension" do
    osdd_response_str = <<-eos
      <os:OpenSearchDescription
        xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
        xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom"
        xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/"
        xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/"
        xmlns:params="http://a9.com/-/spec/opensearch/extensions/parameters/1.0/"
        xmlns:referrer="https://github.com/dewitt/opensearch/blob/master/mediawiki/Specifications/OpenSearch/Extensions/Referrer/1.0"
        xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/"
        xmlns:atom="http://www.w3.org/2005/Atom" >
        <os:ShortName>CMR Collections</os:ShortName>
        <os:Description>NASA CMR Collection search using geo, time and parameter extensions</os:Description>
        <os:Contact>#{ENV['contact']}</os:Contact>
        <os:Url type="application/atom+xml" rel="collection" params:method="GET" template="#{ENV['opensearch_url']}/collections.atom?keyword={os:searchTerms?}&amp;instrument={echo:instrument?}&amp;satellite={eo:platform?}&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;geometry={geo:geometry?}&amp;placeName={geo:name?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;cursor={os:startPage?}&amp;numberOfResults={os:count?}&amp;offset={os:startIndex?}&amp;uid={geo:uid?}&amp;hasGranules={echo:hasGranules?}&amp;isCwic={echo:isCwic?}&amp;isGeoss={echo:isGeoss?}&amp;isCeos={echo:isCeos?}&amp;isEosdis={echo:isEosdis?}&amp;isFedeo={echo:isFedeo?}&amp;provider={echo:provider?}&amp;clientId=foo">
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
        <os:Url type="text/html" rel="collection" params:method="GET" template="#{ENV['opensearch_url']}/collections.html?keyword={os:searchTerms?}&amp;instrument={echo:instrument?}&amp;satellite={eo:platform?}&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;geometry={geo:geometry?}&amp;placeName={geo:name?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;cursor={os:startPage?}&amp;numberOfResults={os:count?}&amp;offset={os:startIndex?}&amp;uid={geo:uid?}&amp;hasGranules={echo:hasGranules?}&amp;isCwic={echo:isCwic?}&amp;isGeoss={echo:isGeoss?}&amp;isCeos={echo:isCeos?}&amp;isEosdis={echo:isEosdis?}&amp;isFedeo={echo:isFedeo?}&amp;provider={echo:provider?}&amp;clientId=foo">
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

    stub_client_id = stub_model(ClientId)
    stub_client_id.clientId = 'foo'

    assign(:client_id_model, stub_client_id)

    render

    expected_doc = Nokogiri::XML(osdd_response_str, nil, 'UTF-8') do |config|
      config.default_xml.noblanks
    end

    actual_doc = Nokogiri::XML(rendered, nil, 'UTF-8') do |config|
      config.default_xml.noblanks
    end

    expect(actual_doc.to_xml(:indent => 2)).to eq(expected_doc.to_xml(:indent => 2))
  end
end
