require 'spec_helper'

describe Collection do
  before(:each) do
    @d = Collection.new({})
    Flipper.disable(:use_cwic_server)
  end
  describe 'minimum bounding rectangle generation' do
    it 'should generate a MBR for a polygon' do

      cat_rest_response_str = <<-eos
              <feed xmlns="http://www.w3.org/2005/Atom">
                <updated>2013-02-13T19:57:44.080Z</updated>
                <id>https://api.echo.nasa.gov/catalog-rest/echo_catalog/datasets.atom?keyword=AIRVBRAD&amp;page_size=1</id>
                <title type="text">CMR collection metadata</title>
                <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                  <updated>2013-02-13T19:57:44.080Z</updated>
                  <id>C190465571-GSFCS4PA</id>
                  <title>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</title>
                  <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</echo:datasetId>
                  <echo:shortName>AIRVBRAD</echo:shortName>
                  <echo:versionId>005</echo:versionId>
                  <echo:dataCenter>GSFCS4PA</echo:dataCenter>
                  <echo:archiveCenter>GEOSDISC</echo:archiveCenter>
                  <time:start>2002-08-30T00:00:00.000Z</time:start>
                  <georss:polygon>57.2230163579929 160.889088 56.6795680749406 160.605005 56.5414925833731 161.594859 57.0829684490569 161.89263 57.2230163579929 160.889088</georss:polygon>
                  <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="http://esipfed.org/ns/fedsearch/1.1/documentation#" />
                  <echo:difId>GES_DISC_AIRVBRAD_V005</echo:difId>
                  <echo:onlineAccessFlag>false</echo:onlineAccessFlag>
                  <echo:browseFlag>false</echo:browseFlag>
                  <echo:hasGranules>true</echo:hasGranules>
                </entry>
              </feed>
      eos
      open_search_response_str = <<-eos
        <feed xmlns="http://www.w3.org/2005/Atom" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/" xmlns:esipdiscovery="http://commons.esipfed.org/ns/discovery/1.2/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml" esipdiscovery:version="1.2">
          <updated>2013-02-13T19:57:44.080Z</updated>
          <id>#{ENV['opensearch_url']}/collections.atom</id>
          <author>
            <name>CMR</name>
            <email>#{ENV['contact']}</email>
          </author>
          <title type="text">CMR collection metadata</title>
          <subtitle type="text">Search parameters: keyword =&gt; AIRVBRAD</subtitle>
          <link href="#{ENV['opensearch_url']}/granules/descriptor_document.xml" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" />
          <link href="#{ENV['opensearch_url']}/collections?cursor=1&amp;numberOfResults=10" hreflang="en-US" type="application/atom+xml" rel="self" />
          <link href="#{ENV['opensearch_url']}/collections?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="last" />
          <link href="#{ENV['opensearch_url']}/collections?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="first" />
          <link href="https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information" hreflang="en-US" type="text/html" rel="describedBy" title="Release Notes" />
          <os:Query xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" role="request" os:searchTerms="AIRVBRAD" />
          <os:totalResults>1</os:totalResults>
          <os:itemsPerPage>10</os:itemsPerPage>
          <os:startIndex>1</os:startIndex>
          <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
            <updated>2013-02-13T19:57:44.080Z</updated>
            <id>#{ENV['opensearch_url']}/collections.atom?uid=C190465571-GSFCS4PA</id>
            <author>
              <name>CMR</name>
              <email>#{ENV['contact']}</email>
            </author>
            <title type="text">AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</title>

            <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="via" />
            <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="via" type="text/html" />
            <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="via" />
            <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="via" />
            <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="via" />
            <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="via" />
            <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="describedBy" type="application/pdf" />
            <link href="http://gcmd.nasa.gov/getdif.htm?GES_DISC_AIRVBRAD_V005" hreflang="en-US" type="text/html" rel="enclosure" title="AIRVBRAD" />
            <link href="#{ENV['opensearch_url']}/granules.atom?clientId=foo&amp;shortName=AIRVBRAD&amp;versionId=005&amp;dataCenter=GSFCS4PA" hreflang="en-US" type="application/atom+xml" rel="search" title="Search for granules" />
            <link href="#{ENV['opensearch_url']}/granules/descriptor_document.xml?collectionConceptId=C190465571-GSFCS4PA&amp;clientId=foo" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" title="Granule OpenSearch Descriptor Document" />
            <link href="#{ENV['public_catalog_rest_endpoint']}concepts/C190465571-GSFCS4PA.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
            <dc:identifier>C190465571-GSFCS4PA</dc:identifier>
            <dc:date>2002-08-30T00:00:00.000Z/</dc:date>
            <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</echo:datasetId>
            <echo:shortName>AIRVBRAD</echo:shortName>
            <echo:versionId>005</echo:versionId>
            <echo:dataCenter>GSFCS4PA</echo:dataCenter>
            <echo:archiveCenter>GEOSDISC</echo:archiveCenter>
            <georss:polygon>57.2230163579929 160.889088 56.6795680749406 160.605005 56.5414925833731 161.594859 57.0829684490569 161.89263 57.2230163579929 160.889088</georss:polygon>
            <georss:box>56.5414925833731 160.605005 57.2230163579929 161.89263</georss:box>
          </entry>
        </feed>
      eos

      catalog_rest_doc = Nokogiri::XML(cat_rest_response_str) do |config|
        config.default_xml.noblanks
      end
      opensearch_doc = Nokogiri::XML(open_search_response_str) do |config|
        config.default_xml.noblanks
      end
      actual = @d.to_open_search_collections(catalog_rest_doc, 1, {:clientId => "foo", :keyword => "AIRVBRAD", :cursor => "1", :numberOfResults => "10"}, "#{ENV['opensearch_url']}/datasets?cursor=1&numberOfResults=10")
      expect(actual.to_xml(:indent => 2)).to eq(opensearch_doc.to_xml(:indent => 2))

    end
    it 'should generate a MBR for a line' do

      cat_rest_response_str = <<-eos
              <feed xmlns="http://www.w3.org/2005/Atom">
                <updated>2013-02-13T19:57:44.080Z</updated>
                <id>https://api.echo.nasa.gov/catalog-rest/echo_catalog/datasets.atom?keyword=AIRVBRAD&amp;page_size=1</id>
                <title type="text">CMR collection metadata</title>
                <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                  <updated>2013-02-13T19:57:44.080Z</updated>
                  <id>C190465571-GSFCS4PA</id>
                  <title>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</title>
                  <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</echo:datasetId>
                  <echo:shortName>AIRVBRAD</echo:shortName>
                  <echo:versionId>005</echo:versionId>
                  <echo:dataCenter>GSFCS4PA</echo:dataCenter>
                  <echo:archiveCenter>GEOSDISC</echo:archiveCenter>
                  <time:start>2002-08-30T00:00:00.000Z</time:start>
                  <georss:line>45.256 -110.45 46.46 -109.48 43.84 -109.86</georss:line>
                  <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="http://esipfed.org/ns/fedsearch/1.1/documentation#" />
                  <echo:difId>GES_DISC_AIRVBRAD_V005</echo:difId>
                  <echo:onlineAccessFlag>false</echo:onlineAccessFlag>
                  <echo:browseFlag>false</echo:browseFlag>
                  <echo:hasGranules>true</echo:hasGranules>
                </entry>
              </feed>
      eos
      open_search_response_str = <<-eos
        <feed xmlns="http://www.w3.org/2005/Atom" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/" xmlns:esipdiscovery="http://commons.esipfed.org/ns/discovery/1.2/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml" esipdiscovery:version="1.2">
          <updated>2013-02-13T19:57:44.080Z</updated>
          <id>#{ENV['opensearch_url']}/collections.atom</id>
          <author>
            <name>CMR</name>
            <email>#{ENV['contact']}</email>
          </author>
          <title type="text">CMR collection metadata</title>
          <subtitle type="text">Search parameters: keyword =&gt; AIRVBRAD</subtitle>
          <link href="#{ENV['opensearch_url']}/granules/descriptor_document.xml" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" />
          <link href="#{ENV['opensearch_url']}/collections?cursor=1&amp;numberOfResults=10" hreflang="en-US" type="application/atom+xml" rel="self" />
          <link href="#{ENV['opensearch_url']}/collections?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="last" />
          <link href="#{ENV['opensearch_url']}/collections?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="first" />
          <link href="https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information" hreflang="en-US" type="text/html" rel="describedBy" title="Release Notes" />
          <os:Query xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" role="request" os:searchTerms="AIRVBRAD" /><os:totalResults>1</os:totalResults>
          <os:itemsPerPage>10</os:itemsPerPage>
          <os:startIndex>1</os:startIndex>
          <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
            <updated>2013-02-13T19:57:44.080Z</updated>
            <id>#{ENV['opensearch_url']}/collections.atom?uid=C190465571-GSFCS4PA</id>
            <author>
              <name>CMR</name>
              <email>#{ENV['contact']}</email>
            </author>
            <title type="text">AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</title>
            <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="via" />
            <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="via" type="text/html" />
            <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="via" />
            <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="via" />
            <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="via" />
            <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="via" />
            <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="describedBy" type="application/pdf" />
            <link href="http://gcmd.nasa.gov/getdif.htm?GES_DISC_AIRVBRAD_V005" hreflang="en-US" type="text/html" rel="enclosure" title="AIRVBRAD" />
            <link href="#{ENV['opensearch_url']}/granules.atom?clientId=foo&amp;shortName=AIRVBRAD&amp;versionId=005&amp;dataCenter=GSFCS4PA" hreflang="en-US" type="application/atom+xml" rel="search" title="Search for granules" />
            <link href="#{ENV['opensearch_url']}/granules/descriptor_document.xml?collectionConceptId=C190465571-GSFCS4PA&amp;clientId=foo" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" title="Granule OpenSearch Descriptor Document" />
            <link href="#{ENV['public_catalog_rest_endpoint']}concepts/C190465571-GSFCS4PA.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
            <dc:identifier>C190465571-GSFCS4PA</dc:identifier>
             <dc:date>2002-08-30T00:00:00.000Z/</dc:date>
            <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</echo:datasetId>
            <echo:shortName>AIRVBRAD</echo:shortName>
            <echo:versionId>005</echo:versionId>
            <echo:dataCenter>GSFCS4PA</echo:dataCenter>
            <echo:archiveCenter>GEOSDISC</echo:archiveCenter>
            <georss:line>45.256 -110.45 46.46 -109.48 43.84 -109.86</georss:line>
            <georss:box>43.84 -110.45 46.46 -109.48</georss:box>
          </entry>
        </feed>
      eos

      catalog_rest_doc = Nokogiri::XML(cat_rest_response_str) do |config|
        config.default_xml.noblanks
      end
      opensearch_doc = Nokogiri::XML(open_search_response_str) do |config|
        config.default_xml.noblanks
      end
      actual = @d.to_open_search_collections(catalog_rest_doc, 1, {:clientId => "foo", :keyword => "AIRVBRAD", :cursor => "1", :numberOfResults => "10"}, "#{ENV['opensearch_url']}/datasets?cursor=1&numberOfResults=10")
      expect(actual.to_xml(:indent => 2)).to eq(opensearch_doc.to_xml(:indent => 2))


    end
    it "should generate a MBR for a point" do

      cat_rest_response_str = <<-eos
              <feed xmlns="http://www.w3.org/2005/Atom">
                <updated>2013-02-13T19:57:44.080Z</updated>
                <id>https://api.echo.nasa.gov/catalog-rest/echo_catalog/datasets.atom?keyword=AIRVBRAD&amp;page_size=1</id>
                <title type="text">CMR collection metadata</title>
                <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                  <updated>2013-02-13T19:57:44.080Z</updated>
                  <id>C190465571-GSFCS4PA</id>
                  <title>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</title>
                  <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</echo:datasetId>
                  <echo:shortName>AIRVBRAD</echo:shortName>
                  <echo:versionId>005</echo:versionId>
                  <echo:dataCenter>GSFCS4PA</echo:dataCenter>
                  <echo:archiveCenter>GEOSDISC</echo:archiveCenter>
                  <time:start>2002-08-30T00:00:00.000Z</time:start>
                  <georss:point>39.1 -96.6</georss:point>
                  <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="http://esipfed.org/ns/fedsearch/1.1/documentation#" />
                  <echo:difId>GES_DISC_AIRVBRAD_V005</echo:difId>
                  <echo:onlineAccessFlag>false</echo:onlineAccessFlag>
                  <echo:browseFlag>false</echo:browseFlag>
                  <echo:hasGranules>true</echo:hasGranules>
                </entry>
              </feed>
      eos
      open_search_response_str = <<-eos
        <feed xmlns="http://www.w3.org/2005/Atom" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/" xmlns:esipdiscovery="http://commons.esipfed.org/ns/discovery/1.2/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml" esipdiscovery:version="1.2">
          <updated>2013-02-13T19:57:44.080Z</updated>
          <id>#{ENV['opensearch_url']}/collections.atom</id>
          <author>
            <name>CMR</name>
            <email>#{ENV['contact']}</email>
          </author>
          <title type="text">CMR collection metadata</title>
          <subtitle type="text">Search parameters: keyword =&gt; AIRVBRAD</subtitle>
          <link href="#{ENV['opensearch_url']}/granules/descriptor_document.xml" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" />
          <link href="#{ENV['opensearch_url']}/collections?cursor=1&amp;numberOfResults=10" hreflang="en-US" type="application/atom+xml" rel="self" />
          <link href="#{ENV['opensearch_url']}/collections?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="last" />
          <link href="#{ENV['opensearch_url']}/collections?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="first" />
          <link href="https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information" hreflang="en-US" type="text/html" rel="describedBy" title="Release Notes" />
          <os:Query xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" role="request" os:searchTerms="AIRVBRAD" />
          <os:totalResults>1</os:totalResults>
          <os:itemsPerPage>10</os:itemsPerPage>
          <os:startIndex>1</os:startIndex>
          <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
            <updated>2013-02-13T19:57:44.080Z</updated>
            <id>#{ENV['opensearch_url']}/collections.atom?uid=C190465571-GSFCS4PA</id>
            <author>
              <name>CMR</name>
              <email>#{ENV['contact']}</email>
            </author>
            <title type="text">AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</title>
            <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="via" />
            <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="via" type="text/html" />
            <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="via" />
            <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="via" />
            <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="via" />
            <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="via" />
            <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="describedBy" type="application/pdf" />
            <link href="http://gcmd.nasa.gov/getdif.htm?GES_DISC_AIRVBRAD_V005" hreflang="en-US" type="text/html" rel="enclosure" title="AIRVBRAD" />
            <link href="#{ENV['opensearch_url']}/granules.atom?clientId=foo&amp;shortName=AIRVBRAD&amp;versionId=005&amp;dataCenter=GSFCS4PA" hreflang="en-US" type="application/atom+xml" rel="search" title="Search for granules" />
            <link href="#{ENV['opensearch_url']}/granules/descriptor_document.xml?collectionConceptId=C190465571-GSFCS4PA&amp;clientId=foo" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" title="Granule OpenSearch Descriptor Document" />
            <link href="#{ENV['public_catalog_rest_endpoint']}concepts/C190465571-GSFCS4PA.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
            <dc:identifier>C190465571-GSFCS4PA</dc:identifier>
            <dc:date>2002-08-30T00:00:00.000Z/</dc:date>
            <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</echo:datasetId>
            <echo:shortName>AIRVBRAD</echo:shortName>
            <echo:versionId>005</echo:versionId>
            <echo:dataCenter>GSFCS4PA</echo:dataCenter>
            <echo:archiveCenter>GEOSDISC</echo:archiveCenter>
            <georss:point>39.1 -96.6</georss:point>
            <georss:box>39.1 -96.6 39.1 -96.6</georss:box>
          </entry>
        </feed>
      eos

      catalog_rest_doc = Nokogiri::XML(cat_rest_response_str) do |config|
        config.default_xml.noblanks
      end
      opensearch_doc = Nokogiri::XML(open_search_response_str) do |config|
        config.default_xml.noblanks
      end
      actual = @d.to_open_search_collections(catalog_rest_doc, 1, {:clientId => "foo", :keyword => "AIRVBRAD", :cursor => "1", :numberOfResults => "10"}, "#{ENV['opensearch_url']}/datasets?cursor=1&numberOfResults=10")
      expect(actual.to_xml(:indent => 2)).to eq(opensearch_doc.to_xml(:indent => 2))
    end
    it "should not generate a MBR for a rectangle" do

      cat_rest_response_str = <<-eos
              <feed xmlns="http://www.w3.org/2005/Atom">
                <updated>2013-02-13T19:57:44.080Z</updated>
                <id>https://api.echo.nasa.gov/catalog-rest/echo_catalog/datasets.atom?keyword=AIRVBRAD&amp;page_size=1</id>
                <title type="text">CMR collection metadata</title>
                <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                  <updated>2013-02-13T19:57:44.080Z</updated>
                  <id>C190465571-GSFCS4PA</id>
                  <title>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</title>
                  <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</echo:datasetId>
                  <echo:shortName>AIRVBRAD</echo:shortName>
                  <echo:versionId>005</echo:versionId>
                  <echo:dataCenter>GSFCS4PA</echo:dataCenter>
                  <echo:archiveCenter>GEOSDISC</echo:archiveCenter>
                  <time:start>2002-08-30T00:00:00.000Z</time:start>
                  <georss:box>-1.36302971839905 -169.459686279297 22.4800090789795 -148.560791015625</georss:box>
                  <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="http://esipfed.org/ns/fedsearch/1.1/documentation#" />
                  <echo:difId>GES_DISC_AIRVBRAD_V005</echo:difId>
                  <echo:onlineAccessFlag>false</echo:onlineAccessFlag>
                  <echo:browseFlag>false</echo:browseFlag>
                  <echo:hasGranules>true</echo:hasGranules>
                </entry>
              </feed>
      eos
      open_search_response_str = <<-eos
        <feed xmlns="http://www.w3.org/2005/Atom" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/" xmlns:esipdiscovery="http://commons.esipfed.org/ns/discovery/1.2/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml" esipdiscovery:version="1.2">
          <updated>2013-02-13T19:57:44.080Z</updated>
          <id>#{ENV['opensearch_url']}/collections.atom</id>
          <author>
            <name>CMR</name>
            <email>#{ENV['contact']}</email>
          </author>
          <title type="text">CMR collection metadata</title>
          <subtitle type="text">Search parameters: keyword =&gt; AIRVBRAD</subtitle>
          <link href="#{ENV['opensearch_url']}/granules/descriptor_document.xml" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" />
          <link href="#{ENV['opensearch_url']}/collections?cursor=1&amp;numberOfResults=10" hreflang="en-US" type="application/atom+xml" rel="self" />
          <link href="#{ENV['opensearch_url']}/collections?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="last" />
          <link href="#{ENV['opensearch_url']}/collections?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="first" />
          <link href="https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information" hreflang="en-US" type="text/html" rel="describedBy" title="Release Notes" />
          <os:Query xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" role="request" os:searchTerms="AIRVBRAD" /><os:totalResults>1</os:totalResults>
          <os:itemsPerPage>10</os:itemsPerPage>
          <os:startIndex>1</os:startIndex>
          <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
            <updated>2013-02-13T19:57:44.080Z</updated>
            <id>#{ENV['opensearch_url']}/collections.atom?uid=C190465571-GSFCS4PA</id>

            <author>
              <name>CMR</name>
              <email>#{ENV['contact']}</email>
            </author>
            <title type="text">AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</title>
            <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="via" />
            <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="via" type="text/html" />
            <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="via" />
            <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="via" />
            <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="via" />
            <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="via" />
            <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="describedBy" type="application/pdf" />
            <link href="http://gcmd.nasa.gov/getdif.htm?GES_DISC_AIRVBRAD_V005" hreflang="en-US" type="text/html" rel="enclosure" title="AIRVBRAD" />
            <link href="#{ENV['opensearch_url']}/granules.atom?clientId=foo&amp;shortName=AIRVBRAD&amp;versionId=005&amp;dataCenter=GSFCS4PA" hreflang="en-US" type="application/atom+xml" rel="search" title="Search for granules" />
            <link href="#{ENV['opensearch_url']}/granules/descriptor_document.xml?collectionConceptId=C190465571-GSFCS4PA&amp;clientId=foo" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" title="Granule OpenSearch Descriptor Document" />
            <link href="#{ENV['public_catalog_rest_endpoint']}concepts/C190465571-GSFCS4PA.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
            <dc:identifier>C190465571-GSFCS4PA</dc:identifier>
            <dc:date>2002-08-30T00:00:00.000Z/</dc:date>
            <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</echo:datasetId>
            <echo:shortName>AIRVBRAD</echo:shortName>
            <echo:versionId>005</echo:versionId>
            <echo:dataCenter>GSFCS4PA</echo:dataCenter>
            <echo:archiveCenter>GEOSDISC</echo:archiveCenter>
            <georss:box>-1.36302971839905 -169.459686279297 22.4800090789795 -148.560791015625</georss:box>
          </entry>
        </feed>
      eos

      catalog_rest_doc = Nokogiri::XML(cat_rest_response_str) do |config|
        config.default_xml.noblanks
      end
      opensearch_doc = Nokogiri::XML(open_search_response_str) do |config|
        config.default_xml.noblanks
      end
      actual = @d.to_open_search_collections(catalog_rest_doc, 1, {:clientId => "foo", :keyword => "AIRVBRAD", :cursor => "1", :numberOfResults => "10"}, "#{ENV['opensearch_url']}/datasets?cursor=1&numberOfResults=10")
      expect(actual.to_xml(:indent => 2)).to eq(opensearch_doc.to_xml(:indent => 2))
    end
  end

  describe "open search to echo parameter conversion" do
    it "should convert keyword" do
      open_search_params = {:keyword => "MODIS"}
      actual = @d.to_cmr_collection_params open_search_params
      expect(actual[:keyword]).to eq("MODIS")
    end
    it "should convert multiple parameters" do
      open_search_params = {:keyword => "MODIS",
                            :startTime => "1999-12-18T00:00:00.000Z",
                            :endTime => "2000-12-18T00:00:00.000Z",
                            :boundingBox => "10, 20, 30, 40",
                            :instrument => "MODIS"}
      actual = @d.to_cmr_collection_params open_search_params
      expect(actual[:temporal]).to eq("1999-12-18T00:00:00.000Z,2000-12-18T00:00:00.000Z")
      expect(actual[:bounding_box]).to eq("10,20,30,40")
      expect(actual[:instrument]).to eq("MODIS")
      expect(actual[:keyword]).to eq("MODIS")
    end
  end
  describe "catalog-rest atom result to open search conversion" do
    it "should convert a single catalog-rest fedeo collection result to a single open search result" do
      cat_rest_response_str = <<-eos
        <feed xmlns="http://www.w3.org/2005/Atom">
          <updated>2013-02-13T19:57:44.080Z</updated>
          <id>https://api.echo.nasa.gov/catalog-rest/echo_catalog/datasets.atom?keyword=AIRVBRAD&amp;page_size=1</id>
          <title type="text">CMR collection metadata</title>
          <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
            <updated>2013-02-13T19:57:44.080Z</updated>
            <id>C190465571-GSFCS4PA</id>
            <title>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</title>
            <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</echo:datasetId>
            <echo:shortName>AIRVBRAD</echo:shortName>
            <echo:versionId>005</echo:versionId>
            <echo:dataCenter>GSFCS4PA</echo:dataCenter>
            <echo:archiveCenter>GEOSDISC</echo:archiveCenter>
            <time:start>2002-08-30T00:00:00.000Z</time:start>
            <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
            <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
            <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
            <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
            <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
            <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
            <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="http://esipfed.org/ns/fedsearch/1.1/documentation#" />
            <echo:difId>GES_DISC_AIRVBRAD_V005</echo:difId>
            <echo:onlineAccessFlag>false</echo:onlineAccessFlag>
            <echo:browseFlag>false</echo:browseFlag>
            <echo:hasGranules>true</echo:hasGranules>
            <echo:tag>
              <echo:tagKey>int.esa.fedeo</echo:tagKey>
            </echo:tag>
            <echo:tag>
              <echo:tagKey>opensearch.granule.osdd</echo:tagKey>
              <echo:data>"https://fedeo.esa.int/opensearch/description.xml?parentIdentifier=EOP:ESA:EARTH-ONLINE:ADAM.Surface.Reflectance.Database"</echo:data>
            </echo:tag>
          </entry>
        </feed>
      eos
      open_search_response_str = <<-eos
  <feed xmlns="http://www.w3.org/2005/Atom" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/" xmlns:esipdiscovery="http://commons.esipfed.org/ns/discovery/1.2/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml" esipdiscovery:version="1.2">
    <updated>2013-02-13T19:57:44.080Z</updated>
    <id>#{ENV['opensearch_url']}/collections.atom</id>
    <author>
      <name>CMR</name>
      <email>#{ENV['contact']}</email>
    </author>
    <title type="text">CMR collection metadata</title>
    <subtitle type="text">Search parameters: keyword =&gt; AIRVBRAD</subtitle>
    <link href="#{ENV['opensearch_url']}/granules/descriptor_document.xml" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" />
    <link href="#{ENV['opensearch_url']}/collections?cursor=1&amp;numberOfResults=10" hreflang="en-US" type="application/atom+xml" rel="self" />
    <link href="#{ENV['opensearch_url']}/collections?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="last" />
    <link href="#{ENV['opensearch_url']}/collections?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="first" />
    <link href="https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information" hreflang="en-US" type="text/html" rel="describedBy" title="Release Notes" />
    <os:Query xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" role="request" os:searchTerms="AIRVBRAD" /><os:totalResults>1</os:totalResults>
    <os:itemsPerPage>10</os:itemsPerPage>
    <os:startIndex>1</os:startIndex>
    <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
      <updated>2013-02-13T19:57:44.080Z</updated>
      <id>#{ENV['opensearch_url']}/collections.atom?uid=C190465571-GSFCS4PA</id>

      <author>
        <name>CMR</name>
        <email>#{ENV['contact']}</email>
      </author>
      <title type="text">AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</title>
      <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="via" />
      <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="via" type="text/html" />
      <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="via" />
      <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="via" />
      <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="via" />
      <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="via" />
      <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="describedBy" type="application/pdf" />
      <link href="http://gcmd.nasa.gov/getdif.htm?GES_DISC_AIRVBRAD_V005" hreflang="en-US" type="text/html" rel="enclosure" title="AIRVBRAD" />
      <link href="https://fedeo.esa.int/opensearch/description.xml?parentIdentifier=EOP:ESA:EARTH-ONLINE:ADAM.Surface.Reflectance.Database" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" title="Non-CMR OpenSearch Provider Granule Open Search Descriptor Document" />
      <link href="#{ENV['public_catalog_rest_endpoint']}concepts/C190465571-GSFCS4PA.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
      <dc:identifier>C190465571-GSFCS4PA</dc:identifier>
      <dc:date>2002-08-30T00:00:00.000Z/</dc:date>
      <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</echo:datasetId>
      <echo:shortName>AIRVBRAD</echo:shortName>
      <echo:versionId>005</echo:versionId>
      <echo:dataCenter>GSFCS4PA</echo:dataCenter>
      <echo:archiveCenter>GEOSDISC</echo:archiveCenter>
      <echo:tag>
        <echo:tagKey>int.esa.fedeo</echo:tagKey>
      </echo:tag>
      <echo:tag>
        <echo:tagKey>opensearch.granule.osdd</echo:tagKey>
        <echo:data>"https://fedeo.esa.int/opensearch/description.xml?parentIdentifier=EOP:ESA:EARTH-ONLINE:ADAM.Surface.Reflectance.Database"</echo:data>
      </echo:tag>
      <echo:is_fedeo>true</echo:is_fedeo>
      </entry>
  </feed>
      eos

      catalog_rest_doc = Nokogiri::XML(cat_rest_response_str) do |config|
        config.default_xml.noblanks
      end
      opensearch_doc = Nokogiri::XML(open_search_response_str) do |config|
        config.default_xml.noblanks
      end
      actual = @d.to_open_search_collections(catalog_rest_doc, 1, {:clientId => "foo", :keyword => "AIRVBRAD", :cursor => "1", :numberOfResults => "10"}, "#{ENV['opensearch_url']}/datasets?cursor=1&numberOfResults=10")
      expect(actual.to_xml(:indent => 2)).to eq(opensearch_doc.to_xml(:indent => 2))
    end
  end

  describe "catalog-rest atom result to open search conversion, without int.esa.fedeo tag" do
    it "should convert a single catalog-rest fedeo collection result to a single open search result" do
      cat_rest_response_str = <<-eos
        <feed xmlns="http://www.w3.org/2005/Atom">
          <updated>2013-02-13T19:57:44.080Z</updated>
          <id>https://api.echo.nasa.gov/catalog-rest/echo_catalog/datasets.atom?keyword=AIRVBRAD&amp;page_size=1</id>
          <title type="text">CMR collection metadata</title>
          <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
            <updated>2013-02-13T19:57:44.080Z</updated>
            <id>C190465571-GSFCS4PA</id>
            <title>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</title>
            <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</echo:datasetId>
            <echo:shortName>AIRVBRAD</echo:shortName>
            <echo:versionId>005</echo:versionId>
            <echo:dataCenter>GSFCS4PA</echo:dataCenter>
            <echo:archiveCenter>GEOSDISC</echo:archiveCenter>
            <time:start>2002-08-30T00:00:00.000Z</time:start>
            <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
            <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
            <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
            <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
            <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
            <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
            <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="http://esipfed.org/ns/fedsearch/1.1/documentation#" />
            <echo:difId>GES_DISC_AIRVBRAD_V005</echo:difId>
            <echo:onlineAccessFlag>false</echo:onlineAccessFlag>
            <echo:browseFlag>false</echo:browseFlag>
            <echo:hasGranules>true</echo:hasGranules>
            <echo:tag>
              <echo:tagKey>opensearch.granule.osdd</echo:tagKey>
              <echo:data>"https://fedeo.esa.int/opensearch/description.xml?parentIdentifier=EOP:ESA:EARTH-ONLINE:ADAM.Surface.Reflectance.Database"</echo:data>
            </echo:tag>
          </entry>
        </feed>
      eos
      open_search_response_str = <<-eos
  <feed xmlns="http://www.w3.org/2005/Atom" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/" xmlns:esipdiscovery="http://commons.esipfed.org/ns/discovery/1.2/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml" esipdiscovery:version="1.2">
    <updated>2013-02-13T19:57:44.080Z</updated>
    <id>#{ENV['opensearch_url']}/collections.atom</id>
    <author>
      <name>CMR</name>
      <email>#{ENV['contact']}</email>
    </author>
    <title type="text">CMR collection metadata</title>
    <subtitle type="text">Search parameters: keyword =&gt; AIRVBRAD</subtitle>
    <link href="#{ENV['opensearch_url']}/granules/descriptor_document.xml" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" />
    <link href="#{ENV['opensearch_url']}/collections?cursor=1&amp;numberOfResults=10" hreflang="en-US" type="application/atom+xml" rel="self" />
    <link href="#{ENV['opensearch_url']}/collections?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="last" />
    <link href="#{ENV['opensearch_url']}/collections?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="first" />
    <link href="https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information" hreflang="en-US" type="text/html" rel="describedBy" title="Release Notes" />
    <os:Query xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" role="request" os:searchTerms="AIRVBRAD" /><os:totalResults>1</os:totalResults>
    <os:itemsPerPage>10</os:itemsPerPage>
    <os:startIndex>1</os:startIndex>
    <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
      <updated>2013-02-13T19:57:44.080Z</updated>
      <id>#{ENV['opensearch_url']}/collections.atom?uid=C190465571-GSFCS4PA</id>

      <author>
        <name>CMR</name>
        <email>#{ENV['contact']}</email>
      </author>
      <title type="text">AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</title>
      <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="via" />
      <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="via" type="text/html" />
      <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="via" />
      <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="via" />
      <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="via" />
      <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="via" />
      <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="describedBy" type="application/pdf" />
      <link href="http://gcmd.nasa.gov/getdif.htm?GES_DISC_AIRVBRAD_V005" hreflang="en-US" type="text/html" rel="enclosure" title="AIRVBRAD" />
      <link href="https://fedeo.esa.int/opensearch/description.xml?parentIdentifier=EOP:ESA:EARTH-ONLINE:ADAM.Surface.Reflectance.Database" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" title="Non-CMR OpenSearch Provider Granule Open Search Descriptor Document" />
      <link href="#{ENV['public_catalog_rest_endpoint']}concepts/C190465571-GSFCS4PA.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
      <dc:identifier>C190465571-GSFCS4PA</dc:identifier>
      <dc:date>2002-08-30T00:00:00.000Z/</dc:date>
      <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</echo:datasetId>
      <echo:shortName>AIRVBRAD</echo:shortName>
      <echo:versionId>005</echo:versionId>
      <echo:dataCenter>GSFCS4PA</echo:dataCenter>
      <echo:archiveCenter>GEOSDISC</echo:archiveCenter>
      <echo:tag>
        <echo:tagKey>opensearch.granule.osdd</echo:tagKey>
        <echo:data>"https://fedeo.esa.int/opensearch/description.xml?parentIdentifier=EOP:ESA:EARTH-ONLINE:ADAM.Surface.Reflectance.Database"</echo:data>
      </echo:tag>
      </entry>
  </feed>
      eos

      catalog_rest_doc = Nokogiri::XML(cat_rest_response_str) do |config|
        config.default_xml.noblanks
      end
      opensearch_doc = Nokogiri::XML(open_search_response_str) do |config|
        config.default_xml.noblanks
      end
      actual = @d.to_open_search_collections(catalog_rest_doc, 1, {:clientId => "foo", :keyword => "AIRVBRAD", :cursor => "1", :numberOfResults => "10"}, "#{ENV['opensearch_url']}/datasets?cursor=1&numberOfResults=10")
      expect(actual.to_xml(:indent => 2)).to eq(opensearch_doc.to_xml(:indent => 2))
    end
  end

  describe "catalog-rest atom result to open search conversion" do
    it "should convert a single catalog-rest result to a single open search result" do
      cat_rest_response_str = <<-eos
      <feed xmlns="http://www.w3.org/2005/Atom">
        <updated>2013-02-13T19:57:44.080Z</updated>
        <id>https://api.echo.nasa.gov/catalog-rest/echo_catalog/datasets.atom?keyword=AIRVBRAD&amp;page_size=1</id>
        <title type="text">CMR collection metadata</title>
        <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
          <updated>2013-02-13T19:57:44.080Z</updated>
          <id>C190465571-GSFCS4PA</id>
          <title>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</title>
          <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</echo:datasetId>
          <echo:shortName>AIRVBRAD</echo:shortName>
          <echo:versionId>005</echo:versionId>
          <echo:dataCenter>GSFCS4PA</echo:dataCenter>
          <echo:archiveCenter>GEOSDISC</echo:archiveCenter>
          <time:start>2002-08-30T00:00:00.000Z</time:start>
          <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
          <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
          <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
          <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
          <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
          <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
          <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="http://esipfed.org/ns/fedsearch/1.1/documentation#" />
          <echo:difId>GES_DISC_AIRVBRAD_V005</echo:difId>
          <echo:onlineAccessFlag>false</echo:onlineAccessFlag>
          <echo:browseFlag>false</echo:browseFlag>
          <echo:hasGranules>true</echo:hasGranules>
        </entry>
      </feed>
      eos
      open_search_response_str = <<-eos
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/" xmlns:esipdiscovery="http://commons.esipfed.org/ns/discovery/1.2/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml" esipdiscovery:version="1.2">
  <updated>2013-02-13T19:57:44.080Z</updated>
  <id>#{ENV['opensearch_url']}/collections.atom</id>
  <author>
    <name>CMR</name>
    <email>#{ENV['contact']}</email>
  </author>
  <title type="text">CMR collection metadata</title>
  <subtitle type="text">Search parameters: keyword =&gt; AIRVBRAD</subtitle>
  <link href="#{ENV['opensearch_url']}/granules/descriptor_document.xml" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" />
  <link href="#{ENV['opensearch_url']}/collections?cursor=1&amp;numberOfResults=10" hreflang="en-US" type="application/atom+xml" rel="self" />
  <link href="#{ENV['opensearch_url']}/collections?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="last" />
  <link href="#{ENV['opensearch_url']}/collections?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="first" />
  <link href="https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information" hreflang="en-US" type="text/html" rel="describedBy" title="Release Notes" />
  <os:Query xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" role="request" os:searchTerms="AIRVBRAD" /><os:totalResults>1</os:totalResults>
  <os:itemsPerPage>10</os:itemsPerPage>
  <os:startIndex>1</os:startIndex>
  <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
    <updated>2013-02-13T19:57:44.080Z</updated>
    <id>#{ENV['opensearch_url']}/collections.atom?uid=C190465571-GSFCS4PA</id>
    <author>
      <name>CMR</name>
      <email>#{ENV['contact']}</email>
    </author>
    <title type="text">AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</title>
    <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="via" />
    <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="via" type="text/html" />
    <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="via" />
    <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="via" />
    <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="via" />
    <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="via" />
    <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="describedBy" type="application/pdf" />
    <link href="http://gcmd.nasa.gov/getdif.htm?GES_DISC_AIRVBRAD_V005" hreflang="en-US" type="text/html" rel="enclosure" title="AIRVBRAD" />
    <link href="#{ENV['opensearch_url']}/granules.atom?clientId=foo&amp;shortName=AIRVBRAD&amp;versionId=005&amp;dataCenter=GSFCS4PA" hreflang="en-US" type="application/atom+xml" rel="search" title="Search for granules" />
    <link href="#{ENV['opensearch_url']}/granules/descriptor_document.xml?collectionConceptId=C190465571-GSFCS4PA&amp;clientId=foo" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" title="Granule OpenSearch Descriptor Document" />
    <link href="#{ENV['public_catalog_rest_endpoint']}concepts/C190465571-GSFCS4PA.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
    <dc:identifier>C190465571-GSFCS4PA</dc:identifier>
    <dc:date>2002-08-30T00:00:00.000Z/</dc:date>
    <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</echo:datasetId>
    <echo:shortName>AIRVBRAD</echo:shortName>
    <echo:versionId>005</echo:versionId>
    <echo:dataCenter>GSFCS4PA</echo:dataCenter>
    <echo:archiveCenter>GEOSDISC</echo:archiveCenter>
  </entry>
</feed>
      eos

      catalog_rest_doc = Nokogiri::XML(cat_rest_response_str) do |config|
        config.default_xml.noblanks
      end
      opensearch_doc = Nokogiri::XML(open_search_response_str) do |config|
        config.default_xml.noblanks
      end
      actual = @d.to_open_search_collections(catalog_rest_doc, 1, {:clientId => "foo", :keyword => "AIRVBRAD", :cursor => "1", :numberOfResults => "10"}, "#{ENV['opensearch_url']}/datasets?cursor=1&numberOfResults=10")
      expect(actual.to_xml(:indent => 2)).to eq(opensearch_doc.to_xml(:indent => 2))
    end

    it "should convert a single catalog-rest result to a single open search result with description" do
      cat_rest_response_str = <<-eos
          <feed xmlns="http://www.w3.org/2005/Atom">
            <updated>2013-02-13T19:57:44.080Z</updated>
            <id>https://api.echo.nasa.gov/catalog-rest/echo_catalog/datasets.atom?keyword=AIRVBRAD&amp;page_size=1</id>
            <title type="text">CMR collection metadata</title>
            <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
              <updated>2013-02-13T19:57:44.080Z</updated>
              <id>C190465571-GSFCS4PA</id>
              <title>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</title>
              <summary type="text">foo</summary>
              <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</echo:datasetId>
              <echo:shortName>AIRVBRAD</echo:shortName>
              <echo:versionId>005</echo:versionId>
              <echo:dataCenter>GSFCS4PA</echo:dataCenter>
              <echo:archiveCenter>GEOSDISC</echo:archiveCenter>
              <time:start>2002-08-30T00:00:00.000Z</time:start>
              <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
              <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
              <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
              <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
              <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
              <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
              <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="http://esipfed.org/ns/fedsearch/1.1/documentation#" />
              <echo:difId>GES_DISC_AIRVBRAD_V005</echo:difId>
              <echo:onlineAccessFlag>false</echo:onlineAccessFlag>
              <echo:browseFlag>false</echo:browseFlag>
              <echo:hasGranules>true</echo:hasGranules>
            </entry>
          </feed>
      eos
      open_search_response_str = <<-eos
    <feed xmlns="http://www.w3.org/2005/Atom" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/" xmlns:esipdiscovery="http://commons.esipfed.org/ns/discovery/1.2/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml" esipdiscovery:version="1.2">
      <updated>2013-02-13T19:57:44.080Z</updated>
      <id>#{ENV['opensearch_url']}/collections.atom</id>
      <author>
        <name>CMR</name>
        <email>#{ENV['contact']}</email>
      </author>
      <title type="text">CMR collection metadata</title>
      <subtitle type="text">Search parameters: keyword =&gt; AIRVBRAD</subtitle>
      <link href="#{ENV['opensearch_url']}/granules/descriptor_document.xml" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" />
      <link href="#{ENV['opensearch_url']}/collections?cursor=1&amp;numberOfResults=10" hreflang="en-US" type="application/atom+xml" rel="self" />
      <link href="#{ENV['opensearch_url']}/collections?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="last" />
      <link href="#{ENV['opensearch_url']}/collections?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="first" />
      <link href="https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information" hreflang="en-US" type="text/html" rel="describedBy" title="Release Notes" />
      <os:Query xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" role="request" os:searchTerms="AIRVBRAD" /><os:totalResults>1</os:totalResults>
      <os:itemsPerPage>10</os:itemsPerPage>
      <os:startIndex>1</os:startIndex>
      <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
        <updated>2013-02-13T19:57:44.080Z</updated>
        <id>#{ENV['opensearch_url']}/collections.atom?uid=C190465571-GSFCS4PA</id>
        <author>
          <name>CMR</name>
          <email>#{ENV['contact']}</email>
        </author>
        <title type="text">AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</title>
        <summary type="text">foo</summary>
        <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="via" />
        <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="via" type="text/html" />
        <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="via" />
        <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="via" />
        <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="via" />
        <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="via" />
        <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="describedBy" type="application/pdf" />
        <link href="http://gcmd.nasa.gov/getdif.htm?GES_DISC_AIRVBRAD_V005" hreflang="en-US" type="text/html" rel="enclosure" title="AIRVBRAD" />
        <link href="#{ENV['opensearch_url']}/granules.atom?clientId=foo&amp;shortName=AIRVBRAD&amp;versionId=005&amp;dataCenter=GSFCS4PA" hreflang="en-US" type="application/atom+xml" rel="search" title="Search for granules" />
        <link href="#{ENV['opensearch_url']}/granules/descriptor_document.xml?collectionConceptId=C190465571-GSFCS4PA&amp;clientId=foo" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" title="Granule OpenSearch Descriptor Document" />
        <link href="#{ENV['public_catalog_rest_endpoint']}concepts/C190465571-GSFCS4PA.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
        <dc:identifier>C190465571-GSFCS4PA</dc:identifier>
        <dc:date>2002-08-30T00:00:00.000Z/</dc:date>
        <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</echo:datasetId>
        <echo:shortName>AIRVBRAD</echo:shortName>
        <echo:versionId>005</echo:versionId>
        <echo:dataCenter>GSFCS4PA</echo:dataCenter>\
        <echo:archiveCenter>GEOSDISC</echo:archiveCenter>
        </entry>
    </feed>
      eos

      catalog_rest_doc = Nokogiri::XML(cat_rest_response_str) do |config|
        config.default_xml.noblanks
      end
      opensearch_doc = Nokogiri::XML(open_search_response_str) do |config|
        config.default_xml.noblanks
      end
      actual = @d.to_open_search_collections(catalog_rest_doc, 1, {:clientId => "foo", :keyword => "AIRVBRAD", :cursor => "1", :numberOfResults => "10"}, "#{ENV['opensearch_url']}/datasets?cursor=1&numberOfResults=10")
      expect(actual.to_xml(:indent => 2)).to eq(opensearch_doc.to_xml(:indent => 2))
    end
    it "should convert a single catalog-rest result to a single open search result with no query parameters" do
      cat_rest_response_str = <<-eos
              <feed xmlns="http://www.w3.org/2005/Atom">
                <updated>2013-02-13T19:57:44.080Z</updated>
                <id>https://api.echo.nasa.gov/catalog-rest/echo_catalog/datasets.atom?keyword=AIRVBRAD&amp;page_size=1</id>
                <title type="text">CMR collection metadata</title>
                <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                  <updated>2013-02-13T19:57:44.080Z</updated>
                  <id>C190465571-GSFCS4PA</id>
                  <title>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</title>
                  <summary type="text">foo</summary>
                  <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</echo:datasetId>
                  <echo:shortName>AIRVBRAD</echo:shortName>
                  <echo:versionId>005</echo:versionId>
                  <echo:dataCenter>GSFCS4PA</echo:dataCenter>
                  <echo:archiveCenter>GEOSDISC</echo:archiveCenter>
                  <time:start>2002-08-30T00:00:00.000Z</time:start>
                  <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="http://esipfed.org/ns/fedsearch/1.1/documentation#" />
                  <echo:difId>GES_DISC_AIRVBRAD_V005</echo:difId>
                  <echo:onlineAccessFlag>false</echo:onlineAccessFlag>
                  <echo:browseFlag>false</echo:browseFlag>
                  <echo:hasGranules>true</echo:hasGranules>
                </entry>
              </feed>
      eos
      open_search_response_str = <<-eos
        <feed xmlns="http://www.w3.org/2005/Atom" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/" xmlns:esipdiscovery="http://commons.esipfed.org/ns/discovery/1.2/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml" esipdiscovery:version="1.2">
          <updated>2013-02-13T19:57:44.080Z</updated>
          <id>#{ENV['opensearch_url']}/collections.atom</id>
          <author>
            <name>CMR</name>
            <email>#{ENV['contact']}</email>
          </author>
          <title type="text">CMR collection metadata</title>
          <subtitle type="text">Search parameters: None</subtitle>
          <link href="#{ENV['opensearch_url']}/granules/descriptor_document.xml" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" />
          <link href="#{ENV['opensearch_url']}/collections?cursor=1&amp;numberOfResults=10" hreflang="en-US" type="application/atom+xml" rel="self" />
          <link href="#{ENV['opensearch_url']}/collections?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="last" />
          <link href="#{ENV['opensearch_url']}/collections?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="first" />
          <link href="https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information" hreflang="en-US" type="text/html" rel="describedBy" title="Release Notes" />
          <os:Query xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" role="request" /><os:totalResults>1</os:totalResults>
          <os:itemsPerPage>10</os:itemsPerPage>
          <os:startIndex>1</os:startIndex>
          <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
            <updated>2013-02-13T19:57:44.080Z</updated>
            <id>#{ENV['opensearch_url']}/collections.atom?uid=C190465571-GSFCS4PA</id>
            <author>
              <name>CMR</name>
              <email>#{ENV['contact']}</email>
            </author>
            <title type="text">AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</title>
            <summary type="text">foo</summary>
            <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="via" />
            <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="via" type="text/html" />
            <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="via" />
            <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="via" />
            <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="via" />
            <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="via" />
            <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="describedBy" type="application/pdf" />
            <link href="http://gcmd.nasa.gov/getdif.htm?GES_DISC_AIRVBRAD_V005" hreflang="en-US" type="text/html" rel="enclosure" title="AIRVBRAD" />
            <link href="#{ENV['opensearch_url']}/granules.atom?clientId=foo&amp;shortName=AIRVBRAD&amp;versionId=005&amp;dataCenter=GSFCS4PA" hreflang="en-US" type="application/atom+xml" rel="search" title="Search for granules" />
            <link href="#{ENV['opensearch_url']}/granules/descriptor_document.xml?collectionConceptId=C190465571-GSFCS4PA&amp;clientId=foo" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" title="Granule OpenSearch Descriptor Document" />
            <link href="#{ENV['public_catalog_rest_endpoint']}concepts/C190465571-GSFCS4PA.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
            <dc:identifier>C190465571-GSFCS4PA</dc:identifier>
            <dc:date>2002-08-30T00:00:00.000Z/</dc:date>
            <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</echo:datasetId>
            <echo:shortName>AIRVBRAD</echo:shortName>
            <echo:versionId>005</echo:versionId>
            <echo:dataCenter>GSFCS4PA</echo:dataCenter>
            <echo:archiveCenter>GEOSDISC</echo:archiveCenter>
            </entry>
        </feed>
      eos

      catalog_rest_doc = Nokogiri::XML(cat_rest_response_str) do |config|
        config.default_xml.noblanks
      end
      opensearch_doc = Nokogiri::XML(open_search_response_str) do |config|
        config.default_xml.noblanks
      end
      actual = @d.to_open_search_collections(catalog_rest_doc, 1, {:clientId => "foo", :cursor => "1", :numberOfResults => "10"}, "#{ENV['opensearch_url']}/datasets?cursor=1&numberOfResults=10")
      expect(actual.to_xml(:indent => 2)).to eq(opensearch_doc.to_xml(:indent => 2))
    end
    it "should convert a single catalog-rest result to a single open search result with spatial parameters" do
      cat_rest_response_str = <<-eos
                  <feed xmlns="http://www.w3.org/2005/Atom">
                    <updated>2013-03-21T16:43:56.190Z</updated>
                    <id>https://api.echo.nasa.gov/catalog-rest/echo_catalog/datasets.atom?keyword=MOD02QKM&amp;page_size=10</id>
                    <title type="text">CMR collection metadata</title>
                    <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                      <id>C90758174-LAADS</id>
                      <title type="text">MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005</title>
                      <summary type="text">This Level 1B collection contains calibrated and geolocated radiances at-aperture for MODIS spectral bands 1 and 2 at 250m resolution.</summary>
                      <updated>2006-03-17T00:00:00.000Z</updated>
                      <echo:datasetId>MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005</echo:datasetId>
                      <echo:shortName>MOD02QKM</echo:shortName>
                      <echo:versionId>5</echo:versionId>
                      <echo:dataCenter>LAADS</echo:dataCenter>
                      <echo:archiveCenter>LAADS</echo:archiveCenter>
                      <echo:processingLevelId>1B</echo:processingLevelId>
                      <time:start>1999-12-18T00:00:00.000Z</time:start>
                      <link href="http://mcst.gsfc.nasa.gov/L1B/product.html" hreflang="en-US" title="MODIS Level 1B Product Information Page at MCST (MiscInformation)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                      <georss:box>-90.0 -180.0 90.0 180.0</georss:box>
                      <echo:difId>MOD02QKM</echo:difId>
                      <echo:onlineAccessFlag>false</echo:onlineAccessFlag>
                      <echo:browseFlag>false</echo:browseFlag>
                      <echo:hasGranules>true</echo:hasGranules>
                    </entry>
                  </feed>
      eos
      open_search_response_str = <<-eos
            <feed xmlns="http://www.w3.org/2005/Atom" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/" xmlns:esipdiscovery="http://commons.esipfed.org/ns/discovery/1.2/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml" esipdiscovery:version="1.2">
              <updated>2013-03-21T16:43:56.190Z</updated>
              <id>#{ENV['opensearch_url']}/collections.atom</id>
              <author>
                <name>CMR</name>
                <email>#{ENV['contact']}</email>
              </author>
              <title type="text">CMR collection metadata</title>
              <subtitle type="text">Search parameters: keyword =&gt; MOD02QKM</subtitle>
              <link href="#{ENV['opensearch_url']}/granules/descriptor_document.xml" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" />
              <link href="#{ENV['opensearch_url']}/collections?cursor=1&amp;numberOfResults=10" hreflang="en-US" type="application/atom+xml" rel="self" />
              <link href="#{ENV['opensearch_url']}/collections?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="last" />
              <link href="#{ENV['opensearch_url']}/collections?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="first" />
              <link href="https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information" hreflang="en-US" type="text/html" rel="describedBy" title="Release Notes" />
              <os:Query xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" role="request" os:searchTerms="MOD02QKM" /><os:totalResults>1</os:totalResults>
              <os:itemsPerPage>10</os:itemsPerPage>
              <os:startIndex>1</os:startIndex>
              <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                <id>#{ENV['opensearch_url']}/collections.atom?uid=C90758174-LAADS</id>
                <author>
                  <name>CMR</name>
                  <email>#{ENV['contact']}</email>
                </author>
                <title type="text">MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005</title>
                <summary type="text">This Level 1B collection contains calibrated and geolocated radiances at-aperture for MODIS spectral bands 1 and 2 at 250m resolution.</summary>
                <updated>2006-03-17T00:00:00.000Z</updated>
                <link href="http://mcst.gsfc.nasa.gov/L1B/product.html" hreflang="en-US" title="MODIS Level 1B Product Information Page at MCST (MiscInformation)" rel="describedBy" type="text/html" />
                <link href="http://gcmd.nasa.gov/getdif.htm?MOD02QKM" hreflang="en-US" type="text/html" rel="enclosure" title="MOD02QKM" />
                <link href="#{ENV['opensearch_url']}/granules.atom?clientId=foo&amp;shortName=MOD02QKM&amp;versionId=5&amp;dataCenter=LAADS" hreflang="en-US" type="application/atom+xml" rel="search" title="Search for granules" />
                <link href="#{ENV['opensearch_url']}/granules/descriptor_document.xml?collectionConceptId=C90758174-LAADS&amp;clientId=foo" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" title="Granule OpenSearch Descriptor Document" />
                <link href="#{ENV['public_catalog_rest_endpoint']}concepts/C90758174-LAADS.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
                <dc:identifier>C90758174-LAADS</dc:identifier>
                <dc:date>1999-12-18T00:00:00.000Z/</dc:date>
                <echo:datasetId>MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005</echo:datasetId>
                <echo:shortName>MOD02QKM</echo:shortName>
                <echo:versionId>5</echo:versionId>
                <echo:dataCenter>LAADS</echo:dataCenter>
                <echo:archiveCenter>LAADS</echo:archiveCenter>
                <echo:processingLevelId>1B</echo:processingLevelId>
                <georss:box>-90.0 -180.0 90.0 180.0</georss:box>
              </entry>
            </feed>
      eos

      catalog_rest_doc = Nokogiri::XML(cat_rest_response_str) do |config|
        config.default_xml.noblanks
      end
      opensearch_doc = Nokogiri::XML(open_search_response_str) do |config|
        config.default_xml.noblanks
      end
      actual = @d.to_open_search_collections(catalog_rest_doc, 1, {:clientId => "foo", :keyword => "MOD02QKM", :cursor => "1", :numberOfResults => "10"}, "#{ENV['opensearch_url']}/datasets?cursor=1&numberOfResults=10")
      expect(actual.to_xml(:indent => 2)).to eq(opensearch_doc.to_xml(:indent => 2))
    end

    it 'should generate the correct start index' do

      cat_rest_response_str = <<-eos
                      <feed xmlns="http://www.w3.org/2005/Atom">
                        <updated>2013-02-13T19:57:44.080Z</updated>
                        <id>https://api.echo.nasa.gov/catalog-rest/echo_catalog/datasets.atom?keyword=AIRVBRAD&amp;page_size=1</id>
                        <title type="text">CMR collection metadata</title>
                        <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                          <updated>2013-02-13T19:57:44.080Z</updated>
                          <id>C190465571-GSFCS4PA</id>
                          <title>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</title>
                          <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</echo:datasetId>
                          <echo:shortName>AIRVBRAD</echo:shortName>
                          <echo:versionId>005</echo:versionId>
                          <echo:dataCenter>GSFCS4PA</echo:dataCenter>
                          <echo:archiveCenter>GEOSDISC</echo:archiveCenter>
                          <time:start>2002-08-30T00:00:00.000Z</time:start>
                          <georss:polygon>57.2230163579929 160.889088 56.6795680749406 160.605005 56.5414925833731 161.594859 57.0829684490569 161.89263 57.2230163579929 160.889088</georss:polygon>
                          <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                          <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                          <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                          <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                          <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                          <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                          <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="http://esipfed.org/ns/fedsearch/1.1/documentation#" />
                          <echo:difId>GES_DISC_AIRVBRAD_V005</echo:difId>
                          <echo:onlineAccessFlag>false</echo:onlineAccessFlag>
                          <echo:browseFlag>false</echo:browseFlag>
                          <echo:hasGranules>true</echo:hasGranules>
                        </entry>
                      </feed>
      eos
      open_search_response_str = <<-eos
                <feed xmlns="http://www.w3.org/2005/Atom" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/" xmlns:esipdiscovery="http://commons.esipfed.org/ns/discovery/1.2/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml" esipdiscovery:version="1.2">
                  <updated>2013-02-13T19:57:44.080Z</updated>
                  <id>#{ENV['opensearch_url']}/collections.atom</id>
                  <author>
                    <name>CMR</name>
                    <email>#{ENV['contact']}</email>
                  </author>
                  <title type="text">CMR collection metadata</title>
                  <subtitle type="text">Search parameters: keyword =&gt; AIRVBRAD</subtitle>
                  <link href="#{ENV['opensearch_url']}/granules/descriptor_document.xml" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" />
                  <link href="#{ENV['opensearch_url']}/collections?cursor=2&amp;numberOfResults=5" hreflang="en-US" type="application/atom+xml" rel="self" />
                  <link href="#{ENV['opensearch_url']}/collections?numberOfResults=5&amp;cursor=4" hreflang="en-US" type="application/atom+xml" rel="last" />
                  <link href="#{ENV['opensearch_url']}/collections?numberOfResults=5&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="previous" />
                  <link href="#{ENV['opensearch_url']}/collections?numberOfResults=5&amp;cursor=3" hreflang="en-US" type="application/atom+xml" rel="next" />
                  <link href="#{ENV['opensearch_url']}/collections?numberOfResults=5&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="first" />
                  <link href="https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information" hreflang="en-US" type="text/html" rel="describedBy" title="Release Notes" />
                  <os:Query xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" role="request" os:searchTerms="AIRVBRAD" /><os:totalResults>18</os:totalResults>
                  <os:itemsPerPage>5</os:itemsPerPage>
                  <os:startIndex>6</os:startIndex>
                  <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                    <updated>2013-02-13T19:57:44.080Z</updated>
                    <id>#{ENV['opensearch_url']}/collections.atom?uid=C190465571-GSFCS4PA</id>
                    <author>
                      <name>CMR</name>
                      <email>#{ENV['contact']}</email>
                    </author>
                    <title type="text">AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</title>
                    <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="via" />
                    <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="via" type="text/html" />
                    <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="via" />
                    <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="via" />
                    <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="via" />
                    <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="via" />
                    <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="describedBy" type="application/pdf" />
                    <link href="http://gcmd.nasa.gov/getdif.htm?GES_DISC_AIRVBRAD_V005" hreflang="en-US" type="text/html" rel="enclosure" title="AIRVBRAD" />
                    <link href="#{ENV['opensearch_url']}/granules.atom?clientId=foo&amp;shortName=AIRVBRAD&amp;versionId=005&amp;dataCenter=GSFCS4PA" hreflang="en-US" type="application/atom+xml" rel="search" title="Search for granules" />
                    <link href="#{ENV['opensearch_url']}/granules/descriptor_document.xml?collectionConceptId=C190465571-GSFCS4PA&amp;clientId=foo" hreflang="en-US" type="application/opensearchdescription+xml" rel="search" title="Granule OpenSearch Descriptor Document" />
                    <link href="#{ENV['public_catalog_rest_endpoint']}concepts/C190465571-GSFCS4PA.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
                    <dc:identifier>C190465571-GSFCS4PA</dc:identifier>
                    <dc:date>2002-08-30T00:00:00.000Z/</dc:date>
                    <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V005</echo:datasetId>
                    <echo:shortName>AIRVBRAD</echo:shortName>
                    <echo:versionId>005</echo:versionId>
                    <echo:dataCenter>GSFCS4PA</echo:dataCenter>
                    <echo:archiveCenter>GEOSDISC</echo:archiveCenter>
                    <georss:polygon>57.2230163579929 160.889088 56.6795680749406 160.605005 56.5414925833731 161.594859 57.0829684490569 161.89263 57.2230163579929 160.889088</georss:polygon>
                    <georss:box>56.5414925833731 160.605005 57.2230163579929 161.89263</georss:box>
                    </entry>
                </feed>
      eos

      catalog_rest_doc = Nokogiri::XML(cat_rest_response_str) do |config|
        config.default_xml.noblanks
      end
      opensearch_doc = Nokogiri::XML(open_search_response_str) do |config|
        config.default_xml.noblanks
      end
      d = Collection.new({})
      actual = d.to_open_search_collections(catalog_rest_doc, 18, {:clientId => 'foo', :keyword => 'AIRVBRAD', :cursor => '2', :numberOfResults => '5'}, "#{ENV['opensearch_url']}/datasets?cursor=2&numberOfResults=5")
      expect(actual.to_xml(:indent => 2)).to eq(opensearch_doc.to_xml(:indent => 2))

    end

  end
  describe "dataset query validation" do
    it "is possible to supply no parameters" do
      params = {}
      dataset = Collection.new(params)
      expect(dataset.valid?).to eq(true)
    end
    describe "clientId" do
      it "is possible to supply a client id 'foo'" do
        params = {:clientId => 'foo'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(true)
      end

      it "is not possible to supply a client id '###'" do
        params = {:clientId => '###'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
      end
    end

    describe "numberOfResults" do
      it "is possible to supply a numberOfResults of 1" do
        params = {:numberOfResults => 1}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(true)
      end

      it "is possible to supply a numberOfResults of '1'" do
        params = {:numberOfResults => '1'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(true)
      end

      it "is possible to supply a numberOfResults of 2000" do
        params = {:numberOfResults => 2000}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(true)
      end

      it "is not possible to supply a numberOfResults of 1.1" do
        params = {:numberOfResults => 1.1}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
      end

      it "is not possible to supply a numberOfResults of -1" do
        params = {:numberOfResults => -1}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
      end

      it "is not possible to supply a numberOfResults of 2001" do
        params = {:numberOfResults => 2001}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
      end

      it "is not possible to supply a numberOfResults of 0" do
        params = {:numberOfResults => 0}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
      end

      it "is not possible to supply a numberOfResults of 'foo'" do
        params = {:numberOfResults => 'foo'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
      end
    end

    describe "cursor" do
      it "is possible to supply a cursor of 1" do
        params = {:cursor => 1}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(true)
      end

      it "is possible to supply a cursor of '1'" do
        params = {:cursor => '1'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(true)
      end

      it "is possible to supply a cursor of 3" do
        params = {:cursor => 3}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(true)
      end

      it "is not possible to supply a cursor of 1.1" do
        params = {:cursor => 1.1}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
      end

      it "is not possible to supply a cursor of -1" do
        params = {:cursor => -1}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
      end

      it "is not possible to supply a cursor of 0" do
        params = {:cursor => 0}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
      end

      it "is not possible to supply a cursor of 'foo'" do
        params = {:cursor => 'foo'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
      end
    end

    describe "startTime" do
      it "is possible to supply a startTime '2010-01-01T00:00:00Z'" do
        params = {:startTime => '2010-01-01T00:00:00Z'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(true)
      end

      it "is possible to supply a startTime '2010-01-01T00:00:00.000Z'" do
        params = {:startTime => '2010-01-01T00:00:00.000Z'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(true)
      end

      it "is not possible to supply a startTime '###'" do
        params = {:startTime => '###'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
        expect(dataset.errors[:startTime]).to eq(['### is not a valid rfc3339 date'])
      end
    end

    describe "endTime" do
      it "is possible to supply a endTime '2010-01-01T00:00:00Z'" do
        params = {:endTime => '2010-01-01T00:00:00Z'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(true)
      end

      it "is possible to supply a endTime '2010-01-01T00:00:00.000Z'" do
        params = {:endTime => '2010-01-01T00:00:00.000Z'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(true)
      end

      it "is not possible to supply a endTime '###'" do
        params = {:endTime => '###'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
        expect(dataset.errors[:endTime]).to eq(['### is not a valid rfc3339 date'])
      end
    end

    describe "geometry" do
      it "is possible to supply a geometry 'POINT (1 2)'" do
        params = {:geometry => 'POINT (1 2)'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(true)
      end

      it "is possible to supply a geometry 'LINESTRING (30 10, 10 30, 40 40)'" do
        params = {:geometry => 'LINESTRING (30 10, 10 30, 40 40)'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(true)
      end

      it "is possible to supply a geometry 'POLYGON ((30 10, 10 20, 20 40, 40 40, 30 10))'" do
        params = {:geometry => 'POLYGON ((30 10, 10 20, 20 40, 40 40, 30 10))'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(true)
      end

      it "is not possible to supply a geometry '###'" do
        params = {:geometry => '###'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
        expect(dataset.errors[:geometry]).to eq(['### is not a valid WKT'])
      end

      it "is not possible to supply a geometry 'MULTIPOINT (10 40, 40 30, 20 20, 30 10)'" do
        params = {:geometry => 'MULTIPOINT (10 40, 40 30, 20 20, 30 10)'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
        expect(dataset.errors[:geometry]).to eq(['MULTIPOINT (10 40, 40 30, 20 20, 30 10) is not supported, please use POINT, LINESTRING or POLYGON'])
      end
    end

    describe "bounding box" do
      it "is possible to supply a boundingBox '-180,-90,180,90'" do
        params = {:boundingBox => '-180,-90,180,90'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(true)
      end
      it "is possible to supply a boundingBox '-180.0,-90.0,180.0,90.0'" do
        params = {:boundingBox => '-180.0,-90.0,180.0,90.0'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(true)
      end
      it "is not possible to supply a boundingBox '-180.0 -90.0 180.0 90.0'" do
        params = {:boundingBox => '-180.0 -90.0 180.0 90.0'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
        expect(dataset.errors[:boundingBox]).to eq(['-180.0 -90.0 180.0 90.0 is not a valid boundingBox'])
      end
      it "is not possible to supply a boundingBox '1,2'" do
        params = {:boundingBox => '1,2'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
        expect(dataset.errors[:boundingBox]).to eq(['1,2 is not a valid boundingBox'])
      end
      it "is not possible to supply a boundingBox '-181.0,-90.0,180.0,90.0'" do
        params = {:boundingBox => '-181.0,-90.0,180.0,90.0'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
        expect(dataset.errors[:boundingBox]).to eq(['-181.0,-90.0,180.0,90.0 is not a valid boundingBox'])
      end
      it "is not possible to supply a boundingBox '-180,-91,180,90'" do
        params = {:boundingBox => '-180,-91,180,90'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
        expect(dataset.errors[:boundingBox]).to eq(['-180,-91,180,90 is not a valid boundingBox'])
      end
      it "is not possible to supply a boundingBox '-180,-90,181,90'" do
        params = {:boundingBox => '-180,-90,181,90'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
        expect(dataset.errors[:boundingBox]).to eq(['-180,-90,181,90 is not a valid boundingBox'])
      end
      it "is not possible to supply a boundingBox '-180,-90,180,91'" do
        params = {:boundingBox => '-180,-90,180,91'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
        expect(dataset.errors[:boundingBox]).to eq(['-180,-90,180,91 is not a valid boundingBox'])
      end
      it "is not possible to supply a boundingBox '###'" do
        params = {:boundingBox => '###'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
        expect(dataset.errors[:boundingBox]).to eq(['### is not a valid boundingBox'])
      end
    end

    describe "point and radius" do
      it "is possible to supply a valid point radius" do
        params = {:lat => '56', :lon => '120', :radius => '10000'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(true)
      end
      it "is not possible to miss lat in point radius search" do
        params = {:lon => '120', :radius => '10000'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
        expect(dataset.errors[:lat]).to eq(['cannot be empty for point radius search'])
      end
      it "is not possible to miss lon in point radius search" do
        params = {:lat => '56', :radius => '10000'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
        expect(dataset.errors[:lon]).to eq(['cannot be empty for point radius search'])
      end
      it "is not possible to miss radius in point radius search" do
        params = {:lat => '56', :lon => '120'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
        expect(dataset.errors[:radius]).to eq(['cannot be empty for point radius search'])
      end
      it "is not possible to miss lon and radius in point radius search" do
        params = {:lat => '56'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
        expect(dataset.errors[:lon]).to eq(['cannot be empty for point radius search'])
        expect(dataset.errors[:radius]).to eq(['cannot be empty for point radius search'])
      end
      it "is not possible to miss lat and radius in point radius search" do
        params = {:lon => '120'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
        expect(dataset.errors[:lat]).to eq(['cannot be empty for point radius search'])
        expect(dataset.errors[:radius]).to eq(['cannot be empty for point radius search'])
      end
      it "is not possible to miss the point in point radius search" do
        params = {:radius => '10000'}
        dataset = Collection.new(params)
        expect(dataset.valid?).to eq(false)
        expect(dataset.errors[:lat]).to eq(['cannot be empty for point radius search'])
        expect(dataset.errors[:lon]).to eq(['cannot be empty for point radius search'])
      end
    end
  end
end
