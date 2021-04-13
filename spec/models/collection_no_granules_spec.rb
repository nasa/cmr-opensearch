require 'spec_helper'

describe Collection do
  before(:each) do
    @d = Collection.new({})
    Flipper.disable(:use_cwic_server)
  end
  describe 'granule level OSDD link generation' do
    it 'should only generate granule level links if the collection has granules' do

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
                <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                  <updated>2013-02-13T19:57:44.080Z</updated>
                  <id>C190465572-GSFCS4PA</id>
                  <title>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V006</title>
                  <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V006</echo:datasetId>
                  <echo:shortName>AIRVBRAD</echo:shortName>
                  <echo:versionId>006</echo:versionId>
                  <echo:dataCenter>GSFCS4PA</echo:dataCenter>
                  <time:start>2002-08-30T00:00:00.000Z</time:start>
                  <georss:polygon>57.2230163579929 160.889088 56.6795680749406 160.605005 56.5414925833731 161.594859 57.0829684490569 161.89263 57.2230163579929 160.889088</georss:polygon>
                  <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="http://esipfed.org/ns/fedsearch/1.1/documentation#" />
                  <echo:difId>GES_DISC_AIRVBRAD_V006</echo:difId>
                  <echo:onlineAccessFlag>false</echo:onlineAccessFlag>
                  <echo:browseFlag>false</echo:browseFlag>
                  <echo:hasGranules>false</echo:hasGranules>
                </entry>
               <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                  <updated>2013-02-13T19:57:44.080Z</updated>
                  <id>C190465573-GSFCS4PA</id>
                  <title>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V007</title>
                  <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V007</echo:datasetId>
                  <echo:shortName>AIRVBRAD</echo:shortName>
                  <echo:versionId>007</echo:versionId>
                  <echo:dataCenter>GSFCS4PA</echo:dataCenter>
                  <time:start>2002-08-30T00:00:00.000Z</time:start>
                  <georss:polygon>57.2230163579929 160.889088 56.6795680749406 160.605005 56.5414925833731 161.594859 57.0829684490569 161.89263 57.2230163579929 160.889088</georss:polygon>
                  <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="http://esipfed.org/ns/fedsearch/1.1/documentation#" />
                  <echo:difId>GES_DISC_AIRVBRAD_V007</echo:difId>
                  <echo:onlineAccessFlag>false</echo:onlineAccessFlag>
                  <echo:browseFlag>false</echo:browseFlag>
                  <echo:hasGranules>foo</echo:hasGranules>
                </entry>
               <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                  <updated>2013-02-13T19:57:44.080Z</updated>
                  <id>C190465574-GSFCS4PA</id>
                  <title>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V008</title>
                  <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V008</echo:datasetId>
                  <echo:shortName>AIRVBRAD</echo:shortName>
                  <echo:versionId>008</echo:versionId>
                  <echo:dataCenter>GSFCS4PA</echo:dataCenter>
                  <time:start>2002-08-30T00:00:00.000Z</time:start>
                  <georss:polygon>57.2230163579929 160.889088 56.6795680749406 160.605005 56.5414925833731 161.594859 57.0829684490569 161.89263 57.2230163579929 160.889088</georss:polygon>
                  <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                  <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="http://esipfed.org/ns/fedsearch/1.1/documentation#" />
                  <echo:difId>GES_DISC_AIRVBRAD_V008</echo:difId>
                  <echo:onlineAccessFlag>false</echo:onlineAccessFlag>
                  <echo:browseFlag>false</echo:browseFlag>
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
            <georss:polygon>57.2230163579929 160.889088 56.6795680749406 160.605005 56.5414925833731 161.594859 57.0829684490569 161.89263 57.2230163579929 160.889088</georss:polygon>
            <georss:box>56.5414925833731 160.605005 57.2230163579929 161.89263</georss:box>
          </entry>
          <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
            <updated>2013-02-13T19:57:44.080Z</updated>
            <id>#{ENV['opensearch_url']}/collections.atom?uid=C190465572-GSFCS4PA</id>
            <author>
              <name>CMR</name>
              <email>#{ENV['contact']}</email>
            </author>
            <title type="text">AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V006</title>

            <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="via" />
            <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="via" type="text/html" />
            <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="via" />
            <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="via" />
            <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="via" />
            <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="via" />
            <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="describedBy" type="application/pdf" />
            <link href="http://gcmd.nasa.gov/getdif.htm?GES_DISC_AIRVBRAD_V006" hreflang="en-US" type="text/html" rel="enclosure" title="AIRVBRAD" />
            <link href="#{ENV['public_catalog_rest_endpoint']}concepts/C190465572-GSFCS4PA.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
            <dc:identifier>C190465572-GSFCS4PA</dc:identifier>
            <dc:date>2002-08-30T00:00:00.000Z/</dc:date>
            <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V006</echo:datasetId>
            <echo:shortName>AIRVBRAD</echo:shortName>
            <echo:versionId>006</echo:versionId>
            <echo:dataCenter>GSFCS4PA</echo:dataCenter>
            <georss:polygon>57.2230163579929 160.889088 56.6795680749406 160.605005 56.5414925833731 161.594859 57.0829684490569 161.89263 57.2230163579929 160.889088</georss:polygon>
            <georss:box>56.5414925833731 160.605005 57.2230163579929 161.89263</georss:box>
          </entry>
          <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
            <updated>2013-02-13T19:57:44.080Z</updated>
            <id>#{ENV['opensearch_url']}/collections.atom?uid=C190465573-GSFCS4PA</id>
            <author>
              <name>CMR</name>
              <email>#{ENV['contact']}</email>
            </author>
            <title type="text">AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V007</title>

            <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="via" />
            <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="via" type="text/html" />
            <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="via" />
            <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="via" />
            <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="via" />
            <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="via" />
            <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="describedBy" type="application/pdf" />
            <link href="http://gcmd.nasa.gov/getdif.htm?GES_DISC_AIRVBRAD_V007" hreflang="en-US" type="text/html" rel="enclosure" title="AIRVBRAD" />
            <link href="#{ENV['public_catalog_rest_endpoint']}concepts/C190465573-GSFCS4PA.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
            <dc:identifier>C190465573-GSFCS4PA</dc:identifier>
            <dc:date>2002-08-30T00:00:00.000Z/</dc:date>
            <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V007</echo:datasetId>
            <echo:shortName>AIRVBRAD</echo:shortName>
            <echo:versionId>007</echo:versionId>
            <echo:dataCenter>GSFCS4PA</echo:dataCenter>
            <georss:polygon>57.2230163579929 160.889088 56.6795680749406 160.605005 56.5414925833731 161.594859 57.0829684490569 161.89263 57.2230163579929 160.889088</georss:polygon>
            <georss:box>56.5414925833731 160.605005 57.2230163579929 161.89263</georss:box>
          </entry>
          <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
            <updated>2013-02-13T19:57:44.080Z</updated>
            <id>#{ENV['opensearch_url']}/collections.atom?uid=C190465574-GSFCS4PA</id>
            <author>
              <name>CMR</name>
              <email>#{ENV['contact']}</email>
            </author>
            <title type="text">AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V008</title>

            <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005/" hreflang="en-US" title="Access the AIRS Visible/Near Infrared VIS/NIR) geolocated and calibrated L1B radiances by FTP. (GET DATA : ON-LINE ARCHIVE)" rel="via" />
            <link href="http://mirador.gsfc.nasa.gov/cgi-bin/mirador/homepageAlt.pl?keyword=AIRVBRAD" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data via MIRADOR. (GET DATA : MIRADOR)" rel="via" type="text/html" />
            <link href="http://disc.sci.gsfc.nasa.gov/SSW" hreflang="en-US" title="Access the AIRS Level 1B Visible/Near Infrared (VIS/NIR) Geolocated and Calibrated Radiances data using Simple Subset Wizard (Search and subset  by date and spatial region). (GET DATA : SSW)" rel="via" />
            <link href="http://reverb.echo.nasa.gov/reverb/#utf8=%E2%9C%93&amp;spatial_map=satellite&amp;spatial_type=rectangle&amp;keywords=GES_DISC_AIRVBRAD_V005" hreflang="en-US" title="Refine your granule search with ECHO's next generation Earth Science discovery tool (Reverb) using information from this record. (GET DATA : REVERB)" rel="via" />
            <link href="http://www-airs.jpl.nasa.gov/" hreflang="en-US" title="AIRS home page at NASA/JPL. General information on the AIRS instrument, algorithms, and other AIRS-related activities can be found. (VIEW PROJECT HOME PAGE)" rel="via" />
            <link href="http://disc.gsfc.nasa.gov/AIRS/index.shtml" hreflang="en-US" title="AIRS data support home page at Goddard Earth Sciences Data Information and Service Center/Distributed Active Archive Center (GES DISC DAAC). Online documentation, software to read, visualize and analyze AIRS data and data access information are available from this web site. (VIEW PROJECT HOME PAGE)" rel="via" />
            <link href="ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa//Aqua_AIRS_Level1/AIRVBRAD.005/doc/README.AIRVBRAD.pdf" hreflang="en-US" title="product README file (VIEW RELATED INFORMATION : USER'S GUIDE)" rel="describedBy" type="application/pdf" />
            <link href="http://gcmd.nasa.gov/getdif.htm?GES_DISC_AIRVBRAD_V008" hreflang="en-US" type="text/html" rel="enclosure" title="AIRVBRAD" />
            <link href="#{ENV['public_catalog_rest_endpoint']}concepts/C190465574-GSFCS4PA.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
            <dc:identifier>C190465574-GSFCS4PA</dc:identifier>
            <dc:date>2002-08-30T00:00:00.000Z/</dc:date>
            <echo:datasetId>AIRS/Aqua Level 1B Visible/Near Infrared (VIS/NIR) geolocated and calibrated radiances V008</echo:datasetId>
            <echo:shortName>AIRVBRAD</echo:shortName>
            <echo:versionId>008</echo:versionId>
            <echo:dataCenter>GSFCS4PA</echo:dataCenter>
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
      actual = @d.to_open_search_collections(catalog_rest_doc, 1, {:clientId => "foo", :keyword => "AIRVBRAD", :cursor => "1", :numberOfResults => "10"}, "#{ENV['opensearch_url']}/collections?cursor=1&numberOfResults=10")
      expect(actual.to_xml(:indent => 2)).to eq(opensearch_doc.to_xml(:indent => 2))

    end
  end
end
