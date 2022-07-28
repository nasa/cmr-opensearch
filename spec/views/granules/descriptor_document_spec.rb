require 'spec_helper'

describe "granules/descriptor_document" do
  it "is possible to create a granule open search descriptor document with a valid client id" do
    stub_client_id = stub_model(ClientId)
    stub_client_id.clientId = 'foo'
    assign(:client_id_model, stub_client_id)

    assign(:short_name, 'MOD02QKM')
    assign(:version_id, '005')
    assign(:data_center, 'LAADS')

    render
    expect(rendered).to include("template=\"#{ENV['opensearch_url']}/granules.atom?datasetId={echo:datasetId?}&amp;shortName=MOD02QKM&amp;versionId=005&amp;dataCenter=LAADS&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;geometry={geo:geometry?}&amp;placeName={geo:name?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;cursor={os:startPage?}&amp;numberOfResults={os:count?}&amp;offset={os:startIndex?}&amp;uid={geo:uid?}&amp;parentIdentifier={eo:parentIdentifier?}&amp;clientId=foo\">")
    expect(rendered).to include("template=\"#{ENV['opensearch_url']}/granules.html?datasetId={echo:datasetId?}&amp;shortName=MOD02QKM&amp;versionId=005&amp;dataCenter=LAADS&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;geometry={geo:geometry?}&amp;placeName={geo:name?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;cursor={os:startPage?}&amp;numberOfResults={os:count?}&amp;offset={os:startIndex?}&amp;uid={geo:uid?}&amp;parentIdentifier={eo:parentIdentifier?}&amp;clientId=foo\">")
  end

  it "is comformant with draft 2 of the open search parameter extension" do
    osdd_response_str = <<-eos
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
        <os:Url type="application/atom+xml" rel="results" params:method="GET" template=\"#{ENV['opensearch_url']}/granules.atom?datasetId={echo:datasetId?}&amp;shortName=MOD02QKM&amp;versionId=005&amp;dataCenter=LAADS&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;geometry={geo:geometry?}&amp;placeName={geo:name?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;cursor={os:startPage?}&amp;numberOfResults={os:count?}&amp;offset={os:startIndex?}&amp;uid={geo:uid?}&amp;parentIdentifier={eo:parentIdentifier?}&amp;clientId=foo\">
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
        <os:Url type="text/html" rel="results" params:method="GET" template=\"#{ENV['opensearch_url']}/granules.html?datasetId={echo:datasetId?}&amp;shortName=MOD02QKM&amp;versionId=005&amp;dataCenter=LAADS&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;geometry={geo:geometry?}&amp;placeName={geo:name?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;cursor={os:startPage?}&amp;numberOfResults={os:count?}&amp;offset={os:startIndex?}&amp;uid={geo:uid?}&amp;parentIdentifier={eo:parentIdentifier?}&amp;clientId=foo\">
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

      stub_client_id = stub_model(ClientId)
      stub_client_id.clientId = 'foo'
      assign(:client_id_model, stub_client_id)

      assign(:short_name, 'MOD02QKM')
      assign(:version_id, '005')
      assign(:data_center, 'LAADS')

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

describe "granules/mosdac" do
  it "is possible to create a collection-specific granule open search descriptor document with a valid client id" do
    stub_client_id = stub_model(ClientId)
    stub_client_id.clientId = 'foo'
    assign(:client_id_model, stub_client_id)

    assign(:dataset_id, '3DIMG_L2B_HEM')

    render
    expect(rendered).to include("template=\"https://mosdac.gov.in/apios/datasets.atom?datasetId=3DIMG_L2B_HEM&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;startIndex={startPage?}&amp;count={count?}&amp;gId={gId?}&amp;clientId=foo\">")
    expect(rendered).to include("template=\"https://mosdac.gov.in/opensearch/collections.atom?keyword={searchTerms?}&amp;instrument={echo:instrument?}&amp;satellite={eo:platform?}&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;startIndex={startPage?}&amp;count={count?}&amp;clientId=foo\">")
  end

  it "is possible to create a collection-specific granule open search descriptor document without a valid client id" do
    stub_client_id = stub_model(ClientId)
    stub_client_id.clientId = ''
    assign(:client_id_model, stub_client_id)

    assign(:dataset_id, '3DIMG_L2B_HEM')

    render
    expect(rendered).to include("template=\"https://mosdac.gov.in/apios/datasets.atom?datasetId=3DIMG_L2B_HEM&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;startIndex={startPage?}&amp;count={count?}&amp;gId={gId?}\">")
    expect(rendered).to include("template=\"https://mosdac.gov.in/opensearch/collections.atom?keyword={searchTerms?}&amp;instrument={echo:instrument?}&amp;satellite={eo:platform?}&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;startIndex={startPage?}&amp;count={count?}\">")
  end

  it "is possible to create a collection-specific granule open search descriptor document with a whitespace client id" do
    stub_client_id = stub_model(ClientId)
    stub_client_id.clientId = ' '
    assign(:client_id_model, stub_client_id)

    assign(:dataset_id, '3DIMG_L2B_HEM')

    render
    expect(rendered).to include("template=\"https://mosdac.gov.in/apios/datasets.atom?datasetId=3DIMG_L2B_HEM&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;startIndex={startPage?}&amp;count={count?}&amp;gId={gId?}\">")
    expect(rendered).to include("template=\"https://mosdac.gov.in/opensearch/collections.atom?keyword={searchTerms?}&amp;instrument={echo:instrument?}&amp;satellite={eo:platform?}&amp;boundingBox={geo:box?}&amp;lat={geo:lat?}&amp;lon={geo:lon?}&amp;radius={geo:radius?}&amp;startTime={time:start?}&amp;endTime={time:end?}&amp;startIndex={startPage?}&amp;count={count?}\">")
  end
end

describe "granules/ccmeo" do
  it "is possible to create a collection-specific granule open search descriptor document with a valid client id" do
    stub_client_id = stub_model(ClientId)
    stub_client_id.clientId = 'foo'
    assign(:client_id_model, stub_client_id)

    render
    expect(rendered).to include("template=\"https://eodms-sgdot.nrcan-rncan.gc.ca/apps/cgi/opensearch/eodms_opensearch_r1.sh?q=&amp;id={geo:id?}&amp;bbox={geo:box?}&amp;dtstart={time:start?}&amp;dtend={time:end?}&amp;pw={startPage?}&amp;startIndex={startIndex?}&amp;count={count?}&amp;clientId=foo\">")
  end

  it "is possible to create a collection-specific granule open search descriptor document with a blank client id" do
    stub_client_id = stub_model(ClientId)
    assign(:client_id_model, stub_client_id)

    render
    expect(rendered).to include("template=\"https://eodms-sgdot.nrcan-rncan.gc.ca/apps/cgi/opensearch/eodms_opensearch_r1.sh?q=&amp;id={geo:id?}&amp;bbox={geo:box?}&amp;dtstart={time:start?}&amp;dtend={time:end?}&amp;pw={startPage?}&amp;startIndex={startIndex?}&amp;count={count?}\">")
  end

  it "is possible to create a collection-specific granule open search descriptor document with a whitespace client id" do
    stub_client_id = stub_model(ClientId)
    stub_client_id.clientId = ' '
    assign(:client_id_model, stub_client_id)

    render
    expect(rendered).to include("template=\"https://eodms-sgdot.nrcan-rncan.gc.ca/apps/cgi/opensearch/eodms_opensearch_r1.sh?q=&amp;id={geo:id?}&amp;bbox={geo:box?}&amp;dtstart={time:start?}&amp;dtend={time:end?}&amp;pw={startPage?}&amp;startIndex={startIndex?}&amp;count={count?}\">")
  end

  it "creates a collection-specific granule open search descriptor document with a temporal range limit of 14 days" do
    stub_client_id = stub_model(ClientId)
    stub_client_id.clientId = 'foo'
    assign(:client_id_model, stub_client_id)

    render
    expect(rendered).to include("<params:Parameter name=\"dtend\" value=\"{time:end}\" minimum=\"0\"  minInclusive=\"\" maxInclusive=\"\" maxPeriod=\"P14D\" relativeTo=\"{time:start}\" title=\"Temporal End\" />")
  end
end

describe "granules/eumetsat" do
  it "is possible to create a collection-specific granule open search descriptor document with a valid client id" do
    stub_client_id = stub_model(ClientId)
    stub_client_id.clientId = 'foo'
    assign(:client_id_model, stub_client_id)

    render
    expect(rendered).to include("template=\"https://navigator.eumetsat.int/eopos?pi=&amp;pw={startPage?}&amp;si={startIndex?}&amp;c={count?}&amp;bbox={geo:box?}&amp;dtstart={time:start?}&amp;dtend={time:end}&amp;iqd={eop:productQualityStatus?}&amp;clientId=foo\">")
  end

  it "is possible to create a collection-specific granule open search descriptor document with a blank client id" do
    stub_client_id = stub_model(ClientId)
    assign(:client_id_model, stub_client_id)

    render
    expect(rendered).to include("template=\"https://navigator.eumetsat.int/eopos?pi=&amp;pw={startPage?}&amp;si={startIndex?}&amp;c={count?}&amp;bbox={geo:box?}&amp;dtstart={time:start?}&amp;dtend={time:end}&amp;iqd={eop:productQualityStatus?}\">")
  end

  it "is possible to create a collection-specific granule open search descriptor document with a whitespace client id" do
    stub_client_id = stub_model(ClientId)
    stub_client_id.clientId = ' '
    assign(:client_id_model, stub_client_id)

    render
    expect(rendered).to include("template=\"https://navigator.eumetsat.int/eopos?pi=&amp;pw={startPage?}&amp;si={startIndex?}&amp;c={count?}&amp;bbox={geo:box?}&amp;dtstart={time:start?}&amp;dtend={time:end}&amp;iqd={eop:productQualityStatus?}\">")
  end

  it "creates a collection-specific granule open search descriptor document with a temporal range limit of 30 days" do
    stub_client_id = stub_model(ClientId)
    stub_client_id.clientId = 'foo'
    assign(:client_id_model, stub_client_id)

    render
    expect(rendered).to include("<params:Parameter name=\"dtend\" value=\"{time:end}\" minimum=\"0\"  minInclusive=\"\" maxInclusive=\"\" maxPeriod=\"P30D\" relativeTo=\"{time:start}\" title=\"Temporal End\" />")
  end
end

describe "granules/nrsc" do
  it "is possible to create a collection-specific granule open search descriptor document with a valid client id" do
    stub_client_id = stub_model(ClientId)
    stub_client_id.clientId = 'foo'
    assign(:client_id_model, stub_client_id)

    assign(:dataset_id, 'P6_AWIF_STUC00GTD')

    render
    expect(rendered).to include("template=\"https://bhoonidhi.nrsc.gov.in/MetaSearch/irsSearch?datasetId=P6_AWIF_STUC00GTD&amp;geoBox={geo:box?}&amp;startIndex={startIndex}&amp;count={count?}&amp;timeStart={time:start?}&amp;timeEnd={time:end?}&amp;clientId=foo\">")
  end

  it "is possible to create a collection-specific granule open search descriptor document with a blank client id" do
    stub_client_id = stub_model(ClientId)
    assign(:client_id_model, stub_client_id)

    assign(:dataset_id, 'P6_AWIF_STUC00GTD')

    render
    expect(rendered).to include("template=\"https://bhoonidhi.nrsc.gov.in/MetaSearch/irsSearch?datasetId=P6_AWIF_STUC00GTD&amp;geoBox={geo:box?}&amp;startIndex={startIndex}&amp;count={count?}&amp;timeStart={time:start?}&amp;timeEnd={time:end?}\">")
  end

  it "is possible to create a collection-specific granule open search descriptor document with a whitespace client id" do
    stub_client_id = stub_model(ClientId)
    stub_client_id.clientId = ' '
    assign(:client_id_model, stub_client_id)

    assign(:dataset_id, 'P6_AWIF_STUC00GTD')

    render
    expect(rendered).to include("template=\"https://bhoonidhi.nrsc.gov.in/MetaSearch/irsSearch?datasetId=P6_AWIF_STUC00GTD&amp;geoBox={geo:box?}&amp;startIndex={startIndex}&amp;count={count?}&amp;timeStart={time:start?}&amp;timeEnd={time:end?}\">")
  end
end

describe "granules/usgslsi" do
  it "is possible to create a collection-specific granule open search descriptor document with a valid client id" do
    stub_client_id = stub_model(ClientId)
    stub_client_id.clientId = 'foo'
    assign(:client_id_model, stub_client_id)

    assign(:dataset_id, 'CALVAL_IS_TUZGOLU_TURKEY')

    render
    expect(rendered).to include("template=\"https://m2m.cr.usgs.gov/api/open-search/granules.atom?uid={uid}&amp;datasetName=CALVAL_IS_TUZGOLU_TURKEY&amp;entryId={lta:entryId}&amp;startIndex={startIndex?}&amp;count={count?}&amp;timeStart={time:start?}&amp;timeEnd={time:end?}&amp;geoBox={geo:box?}&amp;clientId=foo\">")
  end

  it "is possible to create a collection-specific granule open search descriptor document with a valid client id" do
    stub_client_id = stub_model(ClientId)
    assign(:client_id_model, stub_client_id)

    assign(:dataset_id, 'CALVAL_IS_TUZGOLU_TURKEY')

    render
    expect(rendered).to include("template=\"https://m2m.cr.usgs.gov/api/open-search/granules.atom?uid={uid}&amp;datasetName=CALVAL_IS_TUZGOLU_TURKEY&amp;entryId={lta:entryId}&amp;startIndex={startIndex?}&amp;count={count?}&amp;timeStart={time:start?}&amp;timeEnd={time:end?}&amp;geoBox={geo:box?}\">")
  end

  it "is possible to create a collection-specific granule open search descriptor document with a whitespace client id" do
    stub_client_id = stub_model(ClientId)
    stub_client_id.clientId = ' '
    assign(:client_id_model, stub_client_id)

    assign(:dataset_id, 'CALVAL_IS_TUZGOLU_TURKEY')

    render
    expect(rendered).to include("template=\"https://m2m.cr.usgs.gov/api/open-search/granules.atom?uid={uid}&amp;datasetName=CALVAL_IS_TUZGOLU_TURKEY&amp;entryId={lta:entryId}&amp;startIndex={startIndex?}&amp;count={count?}&amp;timeStart={time:start?}&amp;timeEnd={time:end?}&amp;geoBox={geo:box?}\">")
  end
end
