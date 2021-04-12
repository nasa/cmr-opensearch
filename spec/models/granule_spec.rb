require 'spec_helper'

describe Granule do
  before(:each) do
    @g = Granule.new
  end
  describe "minimum bounding rectangle generation" do
    it "should generate a MBR for a polygon" do

      cat_rest_response_str = <<-eos
              <feed xmlns="http://www.w3.org/2005/Atom">
                <updated>2013-02-14T15:51:38.801Z</updated>
                <id>https://api.echo.nasa.gov/catalog-rest/echo_catalog/granules.atom?short_name=MOD02QKM&amp;version=5&amp;provider=LAADS&amp;page_num=1&amp;page_size=1</id>
                <title type="text">CMR granule metadata</title>
                <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                  <id>G92789465-LAADS</id>
                  <title>LAADS:4847654</title>
                  <updated>2013-02-14T15:51:38.801Z</updated>
                  <echo:datasetId>MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005</echo:datasetId>
                  <echo:producerGranuleId>MOD02QKM.A2000055.0005.005.2010029230803.hdf</echo:producerGranuleId>
                  <echo:dataCenter>LAADS</echo:dataCenter>
                  <time:start>2000-02-24T00:05:00.000Z</time:start>
                  <time:end>2000-02-24T00:10:00.000Z</time:end>
                  <georss:polygon>57.2230163579929 160.889088 56.6795680749406 160.605005 56.5414925833731 161.594859 57.0829684490569 161.89263 57.2230163579929 160.889088</georss:polygon>
                  <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOD02QKM/2000/055/MOD02QKM.A2000055.0005.005.2010029230803.hdf" hreflang="en-US" rel="http://esipfed.org/ns/fedsearch/1.1/data#" />
                  <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOBRGB/2000/055/MOBRGB.A2000055.0005.005.2006253053718.jpg" hreflang="en-US" rel="http://esipfed.org/ns/fedsearch/1.1/browse#" />
                  <echo:onlineAccessFlag>true</echo:onlineAccessFlag>
                  <echo:browseFlag>true</echo:browseFlag>
                  <echo:dayNightFlag>BOTH</echo:dayNightFlag>
                </entry>
              </feed>
      eos
      open_search_response_str = <<-eos
                <feed xmlns="http://www.w3.org/2005/Atom" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/" xmlns:esipdiscovery="http://commons.esipfed.org/ns/discovery/1.2/"  xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml" esipdiscovery:version="1.2">
                  <updated>2013-02-14T15:51:38.801Z</updated>
                  <id>#{ENV['opensearch_url']}/granules.atom</id>
                  <author>
                    <name>CMR</name>
                    <email>#{ENV['contact']}</email>
                  </author>
                  <title type="text">CMR granule metadata</title>
                  <subtitle type="text">Search parameters: shortName =&gt; MOD02QKM versionId =&gt; 5 dataCenter =&gt; LAADS</subtitle>
                  <link href="#{ENV['opensearch_url']}/granules?datasetId=MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005" hreflang="en-US" type="application/atom+xml" rel="up" />
                  <link href="#{ENV['opensearch_url']}/granules?cursor=1&amp;numberOfResults=10" hreflang="en-US" type="application/atom+xml" rel="self" />
                  <link href="#{ENV['opensearch_url']}/granules?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="last" />
                  <link href="#{ENV['opensearch_url']}/granules?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="first" />
                  <link href="#{ENV['release_page']}" hreflang="en-US" type="text/html" rel="describedBy" title="Release Notes" />
                  <os:Query xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" role="request" echo:dataCenter="LAADS" echo:shortName="MOD02QKM" echo:versionId="5" />
                  <os:totalResults>1</os:totalResults>
                  <os:itemsPerPage>10</os:itemsPerPage>
                  <os:startIndex>1</os:startIndex>
                  <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                    <id>#{ENV['opensearch_url']}/granules.atom?uid=G92789465-LAADS</id>
                    <title type="text">LAADS:4847654</title>
                    <updated>2013-02-14T15:51:38.801Z</updated>
                    <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOD02QKM/2000/055/MOD02QKM.A2000055.0005.005.2010029230803.hdf" hreflang="en-US" rel="enclosure" type="application/x-hdfeos" />
                    <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOBRGB/2000/055/MOBRGB.A2000055.0005.005.2006253053718.jpg" hreflang="en-US" rel="icon" type="image/jpeg" />
                    <link href="#{ENV['public_catalog_rest_endpoint']}concepts/G92789465-LAADS.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
                    <dc:identifier>G92789465-LAADS</dc:identifier>
                    <dc:date>2000-02-24T00:05:00.000Z/2000-02-24T00:10:00.000Z</dc:date>
                    <echo:datasetId>MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005</echo:datasetId>
                    <echo:producerGranuleId>MOD02QKM.A2000055.0005.005.2010029230803.hdf</echo:producerGranuleId>
                    <echo:dataCenter>LAADS</echo:dataCenter>
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
      actual = @g.to_open_search_granules(catalog_rest_doc, 1, {:clientId => "foo", :shortName => "MOD02QKM", :versionId => "5", :dataCenter => "LAADS", :cursor => "1", :numberOfResults => "10"}, "#{ENV['opensearch_url']}/granules?cursor=1&numberOfResults=10")
      expect(actual.to_xml(:indent => 2)).to eq(opensearch_doc.to_xml(:indent => 2))

    end
    it "should generate a MBR for a line" do

      cat_rest_response_str = <<-eos
                    <feed xmlns="http://www.w3.org/2005/Atom">
                      <updated>2013-02-14T15:51:38.801Z</updated>
                      <id>https://api.echo.nasa.gov/catalog-rest/echo_catalog/granules.atom?short_name=MOD02QKM&amp;version=5&amp;provider=LAADS&amp;page_num=1&amp;page_size=1</id>
                      <title type="text">CMR granule metadata</title>
                      <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                        <id>G92789465-LAADS</id>
                        <title>LAADS:4847654</title>
                        <updated>2013-02-14T15:51:38.801Z</updated>
                        <echo:datasetId>MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005</echo:datasetId>
                        <echo:producerGranuleId>MOD02QKM.A2000055.0005.005.2010029230803.hdf</echo:producerGranuleId>
                        <echo:dataCenter>LAADS</echo:dataCenter>
                        <time:start>2000-02-24T00:05:00.000Z</time:start>
                        <time:end>2000-02-24T00:10:00.000Z</time:end>
                        <georss:line>45.256 -110.45 46.46 -109.48 43.84 -109.86</georss:line>
                        <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOD02QKM/2000/055/MOD02QKM.A2000055.0005.005.2010029230803.hdf" hreflang="en-US" rel="http://esipfed.org/ns/fedsearch/1.1/data#" />
                        <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOBRGB/2000/055/MOBRGB.A2000055.0005.005.2006253053718.jpg" hreflang="en-US" rel="http://esipfed.org/ns/fedsearch/1.1/browse#" />
                        <echo:onlineAccessFlag>true</echo:onlineAccessFlag>
                        <echo:browseFlag>true</echo:browseFlag>
                        <echo:dayNightFlag>BOTH</echo:dayNightFlag>
                      </entry>
                    </feed>
      eos
      open_search_response_str = <<-eos
                      <feed xmlns="http://www.w3.org/2005/Atom" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/" xmlns:esipdiscovery="http://commons.esipfed.org/ns/discovery/1.2/"  xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml" esipdiscovery:version="1.2">
                        <updated>2013-02-14T15:51:38.801Z</updated>
                        <id>#{ENV['opensearch_url']}/granules.atom</id>
                        <author>
                          <name>CMR</name>
                          <email>#{ENV['contact']}</email>
                        </author>
                        <title type="text">CMR granule metadata</title>
                        <subtitle type="text">Search parameters: shortName =&gt; MOD02QKM versionId =&gt; 5 dataCenter =&gt; LAADS</subtitle>
                        <link href="#{ENV['opensearch_url']}/granules?datasetId=MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005" hreflang="en-US" type="application/atom+xml" rel="up" />
                        <link href="#{ENV['opensearch_url']}/granules?cursor=1&amp;numberOfResults=10" hreflang="en-US" type="application/atom+xml" rel="self" />
                        <link href="#{ENV['opensearch_url']}/granules?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="last" />
                        <link href="#{ENV['opensearch_url']}/granules?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="first" />
                        <link href="https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information" hreflang="en-US" type="text/html" rel="describedBy" title="Release Notes" />
                        <os:Query xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" role="request" echo:dataCenter="LAADS" echo:shortName="MOD02QKM" echo:versionId="5" />
                        <os:totalResults>1</os:totalResults>
                        <os:itemsPerPage>10</os:itemsPerPage>
                        <os:startIndex>1</os:startIndex>
                        <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                          <id>#{ENV['opensearch_url']}/granules.atom?uid=G92789465-LAADS</id>
                          <title type="text">LAADS:4847654</title>
                          <updated>2013-02-14T15:51:38.801Z</updated>
                          <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOD02QKM/2000/055/MOD02QKM.A2000055.0005.005.2010029230803.hdf" hreflang="en-US" rel="enclosure" type="application/x-hdfeos" />
                          <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOBRGB/2000/055/MOBRGB.A2000055.0005.005.2006253053718.jpg" hreflang="en-US" rel="icon" type="image/jpeg" />
                          <link href="#{ENV['public_catalog_rest_endpoint']}concepts/G92789465-LAADS.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
                          <dc:identifier>G92789465-LAADS</dc:identifier>
                          <dc:date>2000-02-24T00:05:00.000Z/2000-02-24T00:10:00.000Z</dc:date>
                          <echo:datasetId>MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005</echo:datasetId>
                          <echo:producerGranuleId>MOD02QKM.A2000055.0005.005.2010029230803.hdf</echo:producerGranuleId>
                          <echo:dataCenter>LAADS</echo:dataCenter>
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
      actual = actual = @g.to_open_search_granules(catalog_rest_doc, 1, {:clientId => "foo", :shortName => "MOD02QKM", :versionId => "5", :dataCenter => "LAADS", :cursor => "1", :numberOfResults => "10"}, "#{ENV['opensearch_url']}/granules?cursor=1&numberOfResults=10")
      expect(actual.to_xml(:indent => 2)).to eq(opensearch_doc.to_xml(:indent => 2))


    end
    it "should generate a MBR for a point" do

      cat_rest_response_str = <<-eos
                    <feed xmlns="http://www.w3.org/2005/Atom">
                      <updated>2013-02-14T15:51:38.801Z</updated>
                      <id>https://api.echo.nasa.gov/catalog-rest/echo_catalog/granules.atom?short_name=MOD02QKM&amp;version=5&amp;provider=LAADS&amp;page_num=1&amp;page_size=1</id>
                      <title type="text">CMR granule metadata</title>
                      <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                        <id>G92789465-LAADS</id>
                        <title>LAADS:4847654</title>
                        <updated>2013-02-14T15:51:38.801Z</updated>
                        <echo:datasetId>MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005</echo:datasetId>
                        <echo:producerGranuleId>MOD02QKM.A2000055.0005.005.2010029230803.hdf</echo:producerGranuleId>
                        <echo:dataCenter>LAADS</echo:dataCenter>
                        <time:start>2000-02-24T00:05:00.000Z</time:start>
                        <time:end>2000-02-24T00:10:00.000Z</time:end>
                        <georss:point>39.1 -96.6</georss:point>
                        <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOD02QKM/2000/055/MOD02QKM.A2000055.0005.005.2010029230803.hdf" hreflang="en-US" rel="http://esipfed.org/ns/fedsearch/1.1/data#" />
                        <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOBRGB/2000/055/MOBRGB.A2000055.0005.005.2006253053718.jpg" hreflang="en-US" rel="http://esipfed.org/ns/fedsearch/1.1/browse#" />
                        <echo:onlineAccessFlag>true</echo:onlineAccessFlag>
                        <echo:browseFlag>true</echo:browseFlag>
                        <echo:dayNightFlag>BOTH</echo:dayNightFlag>
                      </entry>
                    </feed>
      eos
      open_search_response_str = <<-eos
                      <feed xmlns="http://www.w3.org/2005/Atom" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/" xmlns:esipdiscovery="http://commons.esipfed.org/ns/discovery/1.2/"  xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml" esipdiscovery:version="1.2">
                        <updated>2013-02-14T15:51:38.801Z</updated>
                        <id>#{ENV['opensearch_url']}/granules.atom</id>
                        <author>
                          <name>CMR</name>
                          <email>#{ENV['contact']}</email>
                        </author>
                        <title type="text">CMR granule metadata</title>
                        <subtitle type="text">Search parameters: shortName =&gt; MOD02QKM versionId =&gt; 5 dataCenter =&gt; LAADS</subtitle>
                        <link href="#{ENV['opensearch_url']}/granules?datasetId=MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005" hreflang="en-US" type="application/atom+xml" rel="up" />
                        <link href="#{ENV['opensearch_url']}/granules?cursor=1&amp;numberOfResults=10" hreflang="en-US" type="application/atom+xml" rel="self" />
                        <link href="#{ENV['opensearch_url']}/granules?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="last" />
                        <link href="#{ENV['opensearch_url']}/granules?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="first" />
                        <link href="https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information" hreflang="en-US" type="text/html" rel="describedBy" title="Release Notes" />
                        <os:Query xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" role="request" echo:dataCenter="LAADS" echo:shortName="MOD02QKM" echo:versionId="5" />
                        <os:totalResults>1</os:totalResults>
                        <os:itemsPerPage>10</os:itemsPerPage>
                        <os:startIndex>1</os:startIndex>
                        <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                          <id>#{ENV['opensearch_url']}/granules.atom?uid=G92789465-LAADS</id>
                          <title type="text">LAADS:4847654</title>
                          <updated>2013-02-14T15:51:38.801Z</updated>
                          <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOD02QKM/2000/055/MOD02QKM.A2000055.0005.005.2010029230803.hdf" hreflang="en-US" rel="enclosure" type="application/x-hdfeos" />
                          <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOBRGB/2000/055/MOBRGB.A2000055.0005.005.2006253053718.jpg" hreflang="en-US" rel="icon" type="image/jpeg" />
                          <link href="#{ENV['public_catalog_rest_endpoint']}concepts/G92789465-LAADS.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
                          <dc:identifier>G92789465-LAADS</dc:identifier>
                          <dc:date>2000-02-24T00:05:00.000Z/2000-02-24T00:10:00.000Z</dc:date>
                          <echo:datasetId>MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005</echo:datasetId>
                          <echo:producerGranuleId>MOD02QKM.A2000055.0005.005.2010029230803.hdf</echo:producerGranuleId>
                          <echo:dataCenter>LAADS</echo:dataCenter>
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
      actual = actual = @g.to_open_search_granules(catalog_rest_doc, 1, {:clientId => "foo", :shortName => "MOD02QKM", :versionId => "5", :dataCenter => "LAADS", :cursor => "1", :numberOfResults => "10"}, "#{ENV['opensearch_url']}/granules?cursor=1&numberOfResults=10")
      expect(actual.to_xml(:indent => 2)).to eq(opensearch_doc.to_xml(:indent => 2))
    end
    it "should not generate a MBR for a rectangle" do

      cat_rest_response_str = <<-eos
                    <feed xmlns="http://www.w3.org/2005/Atom">
                      <updated>2013-02-14T15:51:38.801Z</updated>
                      <id>https://api.echo.nasa.gov/catalog-rest/echo_catalog/granules.atom?short_name=MOD02QKM&amp;version=5&amp;provider=LAADS&amp;page_num=1&amp;page_size=1</id>
                      <title type="text">CMR granule metadata</title>
                      <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                        <id>G92789465-LAADS</id>
                        <title>LAADS:4847654</title>
                        <updated>2013-02-14T15:51:38.801Z</updated>
                        <echo:datasetId>MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005</echo:datasetId>
                        <echo:producerGranuleId>MOD02QKM.A2000055.0005.005.2010029230803.hdf</echo:producerGranuleId>
                        <echo:dataCenter>LAADS</echo:dataCenter>
                        <time:start>2000-02-24T00:05:00.000Z</time:start>
                        <time:end>2000-02-24T00:10:00.000Z</time:end>
                        <georss:box>-1.36302971839905 -169.459686279297 22.4800090789795 -148.560791015625</georss:box>
                        <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOD02QKM/2000/055/MOD02QKM.A2000055.0005.005.2010029230803.hdf" hreflang="en-US" rel="http://esipfed.org/ns/fedsearch/1.1/data#" />
                        <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOBRGB/2000/055/MOBRGB.A2000055.0005.005.2006253053718.jpg" hreflang="en-US" rel="http://esipfed.org/ns/fedsearch/1.1/browse#" />
                        <echo:onlineAccessFlag>true</echo:onlineAccessFlag>
                        <echo:browseFlag>true</echo:browseFlag>
                        <echo:dayNightFlag>BOTH</echo:dayNightFlag>
                      </entry>
                    </feed>
      eos
      open_search_response_str = <<-eos
                      <feed xmlns="http://www.w3.org/2005/Atom" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/" xmlns:esipdiscovery="http://commons.esipfed.org/ns/discovery/1.2/"  xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml" esipdiscovery:version="1.2">
                        <updated>2013-02-14T15:51:38.801Z</updated>
                        <id>#{ENV['opensearch_url']}/granules.atom</id>
                        <author>
                          <name>CMR</name>
                          <email>#{ENV['contact']}</email>
                        </author>
                        <title type="text">CMR granule metadata</title>
                        <subtitle type="text">Search parameters: shortName =&gt; MOD02QKM versionId =&gt; 5 dataCenter =&gt; LAADS</subtitle>
                        <link href="#{ENV['opensearch_url']}/granules?datasetId=MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005" hreflang="en-US" type="application/atom+xml" rel="up" />
                        <link href="#{ENV['opensearch_url']}/granules?cursor=1&amp;numberOfResults=10" hreflang="en-US" type="application/atom+xml" rel="self" />
                        <link href="#{ENV['opensearch_url']}/granules?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="last" />
                        <link href="#{ENV['opensearch_url']}/granules?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="first" />
                        <link href="https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information" hreflang="en-US" type="text/html" rel="describedBy" title="Release Notes" />
                        <os:Query xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" role="request" echo:dataCenter="LAADS" echo:shortName="MOD02QKM" echo:versionId="5" />
                        <os:totalResults>1</os:totalResults>
                        <os:itemsPerPage>10</os:itemsPerPage>
                        <os:startIndex>1</os:startIndex>
                        <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                          <id>#{ENV['opensearch_url']}/granules.atom?uid=G92789465-LAADS</id>
                          <title type="text">LAADS:4847654</title>
                          <updated>2013-02-14T15:51:38.801Z</updated>
                          <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOD02QKM/2000/055/MOD02QKM.A2000055.0005.005.2010029230803.hdf" hreflang="en-US" rel="enclosure" type="application/x-hdfeos" />
                          <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOBRGB/2000/055/MOBRGB.A2000055.0005.005.2006253053718.jpg" hreflang="en-US" rel="icon" type="image/jpeg" />
                          <link href="#{ENV['public_catalog_rest_endpoint']}concepts/G92789465-LAADS.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
                          <dc:identifier>G92789465-LAADS</dc:identifier>
                          <dc:date>2000-02-24T00:05:00.000Z/2000-02-24T00:10:00.000Z</dc:date>
                          <echo:datasetId>MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005</echo:datasetId>
                          <echo:producerGranuleId>MOD02QKM.A2000055.0005.005.2010029230803.hdf</echo:producerGranuleId>
                          <echo:dataCenter>LAADS</echo:dataCenter>
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
      actual = actual = @g.to_open_search_granules(catalog_rest_doc, 1, {:clientId => "foo", :shortName => "MOD02QKM", :versionId => "5", :dataCenter => "LAADS", :cursor => "1", :numberOfResults => "10"}, "#{ENV['opensearch_url']}/granules?cursor=1&numberOfResults=10")
      expect(actual.to_xml(:indent => 2)).to eq(opensearch_doc.to_xml(:indent => 2))
    end
  end
  describe "open search to echo parameter conversion" do
    it "should convert shortName to short_name" do
      open_search_params = {:shortName => "MOD02QKM"}
      actual = @g.to_cmr_granule_params open_search_params
      expect(actual[:short_name]).to eq("MOD02QKM")
    end
    it "should convert versionId to version" do
      open_search_params = {:versionId => "5"}
      actual = @g.to_cmr_granule_params open_search_params
      expect(actual[:version]).to eq("5")
    end
    it "should convert dataCenter to provider" do
      open_search_params = {:dataCenter => "LAADS"}
      actual = @g.to_cmr_granule_params open_search_params
      expect(actual[:provider]).to eq("LAADS")
    end
    it "should convert multiple parameters" do
      open_search_params = {:shortName => "MOD02QKM",
                            :versionId => "5",
                            :dataCenter => "LAADS",
                            :startTime => "1999-12-18T00:00:00.000Z",
                            :endTime => "2000-12-18T00:00:00.000Z",
                            :boundingBox => "10, 20, 30, 40",
                            :instrument => "MODIS"}
      actual = @g.to_cmr_granule_params open_search_params
      expect(actual[:temporal]).to eq("1999-12-18T00:00:00.000Z,2000-12-18T00:00:00.000Z")
      expect(actual[:bounding_box]).to eq("10,20,30,40")
      expect(actual[:instrument]).to eq("MODIS")
      expect(actual[:short_name]).to eq("MOD02QKM")
      expect(actual[:version]).to eq("5")
      expect(actual[:provider]).to eq("LAADS")
    end
  end
  describe "catalog-rest atom result to open search conversion" do
    it "should convert a single catalog-rest result to a single open search result" do
      cat_rest_response_str = <<-eos
        <feed xmlns="http://www.w3.org/2005/Atom">
          <updated>2013-02-14T15:51:38.801Z</updated>
          <id>https://api.echo.nasa.gov/catalog-rest/echo_catalog/granules.atom?short_name=MOD02QKM&amp;version=5&amp;provider=LAADS&amp;page_num=1&amp;page_size=1</id>
          <title type="text">CMR granule metadata</title>
          <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
            <id>G92789465-LAADS</id>
            <title>LAADS:4847654</title>
            <updated>2013-02-14T15:51:38.801Z</updated>
            <echo:datasetId>MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005</echo:datasetId>
            <echo:producerGranuleId>MOD02QKM.A2000055.0005.005.2010029230803.hdf</echo:producerGranuleId>
            <echo:dataCenter>LAADS</echo:dataCenter>
            <time:start>2000-02-24T00:05:00.000Z</time:start>
            <time:end>2000-02-24T00:10:00.000Z</time:end>
            <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOD02QKM/2000/055/MOD02QKM.A2000055.0005.005.2010029230803.hdf" hreflang="en-US" rel="http://esipfed.org/ns/fedsearch/1.1/data#" />
            <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOBRGB/2000/055/MOBRGB.A2000055.0005.005.2006253053718.jpg" hreflang="en-US" rel="http://esipfed.org/ns/fedsearch/1.1/browse#" />
            <georss:polygon>84.145074 10.005589 76.501732 146.929625 66.83662 -145.556275 70.511238 -94.81568 84.145074 10.005589</georss:polygon>
            <echo:onlineAccessFlag>true</echo:onlineAccessFlag>
            <echo:browseFlag>true</echo:browseFlag>
            <echo:dayNightFlag>BOTH</echo:dayNightFlag>
          </entry>
        </feed>
      eos
      open_search_response_str = <<-eos
        <feed xmlns="http://www.w3.org/2005/Atom" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/" xmlns:esipdiscovery="http://commons.esipfed.org/ns/discovery/1.2/"  xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml" esipdiscovery:version="1.2">
          <updated>2013-02-14T15:51:38.801Z</updated>
          <id>#{ENV['opensearch_url']}/granules.atom</id>
          <author>
            <name>CMR</name>
            <email>#{ENV['contact']}</email>
          </author>
          <title type="text">CMR granule metadata</title>
          <subtitle type="text">Search parameters: shortName =&gt; MOD02QKM versionId =&gt; 5 dataCenter =&gt; LAADS</subtitle>
          <link href="#{ENV['opensearch_url']}/granules?datasetId=MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005" hreflang="en-US" type="application/atom+xml" rel="up" />
          <link href="#{ENV['opensearch_url']}/granules?cursor=1&amp;numberOfResults=10" hreflang="en-US" type="application/atom+xml" rel="self" />
          <link href="#{ENV['opensearch_url']}/granules?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="last" />
          <link href="#{ENV['opensearch_url']}/granules?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="first" />
          <link href="https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information" hreflang="en-US" type="text/html" rel="describedBy" title="Release Notes" />
          <os:Query xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" role="request" echo:dataCenter="LAADS" echo:shortName="MOD02QKM" echo:versionId="5" />
          <os:totalResults>1</os:totalResults>
          <os:itemsPerPage>10</os:itemsPerPage>
          <os:startIndex>1</os:startIndex>
          <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
            <id>#{ENV['opensearch_url']}/granules.atom?uid=G92789465-LAADS</id>
            <title type="text">LAADS:4847654</title>
            <updated>2013-02-14T15:51:38.801Z</updated>
            <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOD02QKM/2000/055/MOD02QKM.A2000055.0005.005.2010029230803.hdf" hreflang="en-US" rel="enclosure" type="application/x-hdfeos" />
            <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOBRGB/2000/055/MOBRGB.A2000055.0005.005.2006253053718.jpg" hreflang="en-US" rel="icon" type="image/jpeg" />
            <link href="#{ENV['public_catalog_rest_endpoint']}concepts/G92789465-LAADS.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
            <dc:identifier>G92789465-LAADS</dc:identifier>
            <dc:date>2000-02-24T00:05:00.000Z/2000-02-24T00:10:00.000Z</dc:date>
            <echo:datasetId>MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005</echo:datasetId>
            <echo:producerGranuleId>MOD02QKM.A2000055.0005.005.2010029230803.hdf</echo:producerGranuleId>
            <echo:dataCenter>LAADS</echo:dataCenter>
            <georss:polygon>84.145074 10.005589 76.501732 146.929625 66.83662 -145.556275 70.511238 -94.81568 84.145074 10.005589</georss:polygon>
            <georss:box>66.83662 -145.556275 84.145074 146.929625</georss:box>
          </entry>
        </feed>
      eos

      catalog_rest_doc = Nokogiri::XML(cat_rest_response_str) do |config|
        config.default_xml.noblanks
      end
      opensearch_doc = Nokogiri::XML(open_search_response_str) do |config|
        config.default_xml.noblanks
      end
      actual = @g.to_open_search_granules(catalog_rest_doc, 1, {:clientId => "foo", :shortName => "MOD02QKM", :versionId => "5", :dataCenter => "LAADS", :cursor => "1", :numberOfResults => "10"}, "#{ENV['opensearch_url']}/granules?cursor=1&numberOfResults=10")
      expect(actual.to_xml(:indent => 2)).to eq(opensearch_doc.to_xml(:indent => 2))
    end
    it "should convert a single catalog-rest result to a single open search result with documentation link" do
      cat_rest_response_str = <<-eos
        <feed xmlns="http://www.w3.org/2005/Atom">
          <updated>2013-03-21T19:15:52.658Z</updated>
          <id>https://api.echo.nasa.gov/catalog-rest/echo_catalog/granules.atom?short_name=MOD02QKM&amp;version=5&amp;provider=LAADS&amp;page_size=1</id>
          <title type="text">CMR granule metadata</title>
          <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
            <id>G92789465-LAADS</id>
            <title type="text">LAADS:4847654</title>
            <updated>2010-02-02T03:56:37.983Z</updated>
            <echo:datasetId>MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005</echo:datasetId>
            <echo:producerGranuleId>MOD02QKM.A2000055.0005.005.2010029230803.hdf</echo:producerGranuleId>
            <echo:dataCenter>LAADS</echo:dataCenter>
            <time:start>2000-02-24T00:05:00.000Z</time:start>
            <time:end>2000-02-24T00:10:00.000Z</time:end>
            <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOD02QKM/2000/055/MOD02QKM.A2000055.0005.005.2010029230803.hdf" hreflang="en-US" rel="http://esipfed.org/ns/fedsearch/1.1/data#" />
            <link href="http://mcst.gsfc.nasa.gov/L1B/product.html" hreflang="en-US" title="MODIS Level 1B Product Information Page at MCST (MiscInformation)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
            <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOBRGB/2000/055/MOBRGB.A2000055.0005.005.2006253053718.jpg" hreflang="en-US" rel="http://esipfed.org/ns/fedsearch/1.1/browse#" length="602271" />
            <georss:polygon>84.145074 10.005589 76.501732 146.929625 66.83662 -145.556275 70.511238 -94.81568 84.145074 10.005589</georss:polygon>
            <echo:onlineAccessFlag>true</echo:onlineAccessFlag>
            <echo:browseFlag>true</echo:browseFlag>
            <echo:dayNightFlag>BOTH</echo:dayNightFlag>
          </entry>
        </feed>
      eos
      open_search_response_str = <<-eos
        <feed xmlns="http://www.w3.org/2005/Atom" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/" xmlns:esipdiscovery="http://commons.esipfed.org/ns/discovery/1.2/"  xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml" esipdiscovery:version="1.2">
          <updated>2013-03-21T19:15:52.658Z</updated>
          <id>#{ENV['opensearch_url']}/granules.atom</id>
          <author>
          <name>CMR</name>
          <email>#{ENV['contact']}</email>
          </author>
          <title type="text">CMR granule metadata</title>
          <subtitle type="text">Search parameters: shortName =&gt; MOD02QKM versionId =&gt; 5 dataCenter =&gt; LAADS</subtitle>
          <link href="#{ENV['opensearch_url']}/granules?datasetId=MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005" hreflang="en-US" type="application/atom+xml" rel="up" />
          <link href="#{ENV['opensearch_url']}/granules?cursor=1&amp;numberOfResults=10" hreflang="en-US" type="application/atom+xml" rel="self" />
          <link href="#{ENV['opensearch_url']}/granules?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="last" />
          <link href="#{ENV['opensearch_url']}/granules?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="first" />
          <link href="https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information" hreflang="en-US" type="text/html" rel="describedBy" title="Release Notes" />
          <os:Query xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" role="request" echo:dataCenter="LAADS" echo:shortName="MOD02QKM" echo:versionId="5" />
          <os:totalResults>1</os:totalResults>
          <os:itemsPerPage>10</os:itemsPerPage>
          <os:startIndex>1</os:startIndex>
          <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
            <id>#{ENV['opensearch_url']}/granules.atom?uid=G92789465-LAADS</id>
            <title type="text">LAADS:4847654</title>
            <updated>2010-02-02T03:56:37.983Z</updated>
            <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOD02QKM/2000/055/MOD02QKM.A2000055.0005.005.2010029230803.hdf" hreflang="en-US" rel="enclosure" type="application/x-hdfeos" />
            <link href="http://mcst.gsfc.nasa.gov/L1B/product.html" hreflang="en-US" title="MODIS Level 1B Product Information Page at MCST (MiscInformation)" rel="describedBy" type="text/html" />
            <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOBRGB/2000/055/MOBRGB.A2000055.0005.005.2006253053718.jpg" hreflang="en-US" rel="icon" length="602271" type="image/jpeg" />
            <link href="#{ENV['public_catalog_rest_endpoint']}concepts/G92789465-LAADS.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
            <dc:identifier>G92789465-LAADS</dc:identifier>
            <dc:date>2000-02-24T00:05:00.000Z/2000-02-24T00:10:00.000Z</dc:date>
            <echo:datasetId>MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005</echo:datasetId>
            <echo:producerGranuleId>MOD02QKM.A2000055.0005.005.2010029230803.hdf</echo:producerGranuleId>
            <echo:dataCenter>LAADS</echo:dataCenter>
            <georss:polygon>84.145074 10.005589 76.501732 146.929625 66.83662 -145.556275 70.511238 -94.81568 84.145074 10.005589</georss:polygon>
            <georss:box>66.83662 -145.556275 84.145074 146.929625</georss:box>
          </entry>
        </feed>
      eos
      catalog_rest_doc = Nokogiri::XML(cat_rest_response_str) do |config|
        config.default_xml.noblanks
      end
      opensearch_doc = Nokogiri::XML(open_search_response_str) do |config|
        config.default_xml.noblanks
      end
      actual = @g.to_open_search_granules(catalog_rest_doc, 1, {:clientId => "foo", :shortName => "MOD02QKM", :versionId => "5", :dataCenter => "LAADS", :cursor => "1", :numberOfResults => "10"}, "#{ENV['opensearch_url']}/granules?cursor=1&numberOfResults=10")
      expect(actual.to_xml(:indent => 2)).to eq(opensearch_doc.to_xml(:indent => 2))
    end

    it 'should convert inherited attribute to echo:inherited' do
          cat_rest_response_str = <<-eos
            <feed xmlns="http://www.w3.org/2005/Atom">
              <updated>2013-03-21T19:15:52.658Z</updated>
              <id>https://api.echo.nasa.gov/catalog-rest/echo_catalog/granules.atom?short_name=MOD02QKM&amp;version=5&amp;provider=LAADS&amp;page_size=1</id>
              <title type="text">CMR granule metadata</title>
              <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                <id>G92789465-LAADS</id>
                <title type="text">LAADS:4847654</title>
                <updated>2010-02-02T03:56:37.983Z</updated>
                <echo:datasetId>MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005</echo:datasetId>
                <echo:producerGranuleId>MOD02QKM.A2000055.0005.005.2010029230803.hdf</echo:producerGranuleId>
                <echo:dataCenter>LAADS</echo:dataCenter>
                <time:start>2000-02-24T00:05:00.000Z</time:start>
                <time:end>2000-02-24T00:10:00.000Z</time:end>
                <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOD02QKM/2000/055/MOD02QKM.A2000055.0005.005.2010029230803.hdf" hreflang="en-US" rel="http://esipfed.org/ns/fedsearch/1.1/data#" />
                <link href="http://mcst.gsfc.nasa.gov/L1B/product.html" hreflang="en-US" title="MODIS Level 1B Product Information Page at MCST (MiscInformation)" rel="http://esipfed.org/ns/fedsearch/1.1/metadata#" />
                <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOBRGB/2000/055/MOBRGB.A2000055.0005.005.2006253053718.jpg" hreflang="en-US" rel="http://esipfed.org/ns/fedsearch/1.1/browse#" length="602271" inherited="true" />
                <georss:polygon>84.145074 10.005589 76.501732 146.929625 66.83662 -145.556275 70.511238 -94.81568 84.145074 10.005589</georss:polygon>
                <echo:onlineAccessFlag>true</echo:onlineAccessFlag>
                <echo:browseFlag>true</echo:browseFlag>
                <echo:dayNightFlag>BOTH</echo:dayNightFlag>
              </entry>
            </feed>
          eos
          open_search_response_str = <<-eos
            <feed xmlns="http://www.w3.org/2005/Atom" xmlns:os="http://a9.com/-/spec/opensearch/1.1/" xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/" xmlns:esipdiscovery="http://commons.esipfed.org/ns/discovery/1.2/"  xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml" esipdiscovery:version="1.2">
              <updated>2013-03-21T19:15:52.658Z</updated>
              <id>#{ENV['opensearch_url']}/granules.atom</id>
              <author>
              <name>CMR</name>
              <email>#{ENV['contact']}</email>
              </author>
              <title type="text">CMR granule metadata</title>
              <subtitle type="text">Search parameters: shortName =&gt; MOD02QKM versionId =&gt; 5 dataCenter =&gt; LAADS</subtitle>
              <link href="#{ENV['opensearch_url']}/granules?datasetId=MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005" hreflang="en-US" type="application/atom+xml" rel="up" />
              <link href="#{ENV['opensearch_url']}/granules?cursor=1&amp;numberOfResults=10" hreflang="en-US" type="application/atom+xml" rel="self" />
              <link href="#{ENV['opensearch_url']}/granules?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="last" />
              <link href="#{ENV['opensearch_url']}/granules?numberOfResults=10&amp;cursor=1" hreflang="en-US" type="application/atom+xml" rel="first" />
              <link href="https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information" hreflang="en-US" type="text/html" rel="describedBy" title="Release Notes" />
              <os:Query xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" role="request" echo:dataCenter="LAADS" echo:shortName="MOD02QKM" echo:versionId="5" />
              <os:totalResults>1</os:totalResults>
              <os:itemsPerPage>10</os:itemsPerPage>
              <os:startIndex>1</os:startIndex>
              <entry xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" xmlns:echo="https://cmr.earthdata.nasa.gov/search/site/docs/search/api.html#atom" xmlns:gml="http://www.opengis.net/gml">
                <id>#{ENV['opensearch_url']}/granules.atom?uid=G92789465-LAADS</id>
                <title type="text">LAADS:4847654</title>
                <updated>2010-02-02T03:56:37.983Z</updated>
                <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOD02QKM/2000/055/MOD02QKM.A2000055.0005.005.2010029230803.hdf" hreflang="en-US" rel="enclosure" type="application/x-hdfeos" />
                <link href="http://mcst.gsfc.nasa.gov/L1B/product.html" hreflang="en-US" title="MODIS Level 1B Product Information Page at MCST (MiscInformation)" rel="describedBy" type="text/html" />
                <link href="ftp://ladsftp.nascom.nasa.gov/allData/5/MOBRGB/2000/055/MOBRGB.A2000055.0005.005.2006253053718.jpg" hreflang="en-US" rel="icon" length="602271" echo:inherited="true" type="image/jpeg" />
                <link href="#{ENV['public_catalog_rest_endpoint']}concepts/G92789465-LAADS.xml" hreflang="en-US" type="application/xml" rel="via" title="Product metadata" />
                <dc:identifier>G92789465-LAADS</dc:identifier>
                <dc:date>2000-02-24T00:05:00.000Z/2000-02-24T00:10:00.000Z</dc:date>
                <echo:datasetId>MODIS/Terra Calibrated Radiances 5-Min L1B Swath 250m V005</echo:datasetId>
                <echo:producerGranuleId>MOD02QKM.A2000055.0005.005.2010029230803.hdf</echo:producerGranuleId>
                <echo:dataCenter>LAADS</echo:dataCenter>
                <georss:polygon>84.145074 10.005589 76.501732 146.929625 66.83662 -145.556275 70.511238 -94.81568 84.145074 10.005589</georss:polygon>
                <georss:box>66.83662 -145.556275 84.145074 146.929625</georss:box>
              </entry>
            </feed>
          eos
          catalog_rest_doc = Nokogiri::XML(cat_rest_response_str) do |config|
            config.default_xml.noblanks
          end
          opensearch_doc = Nokogiri::XML(open_search_response_str) do |config|
            config.default_xml.noblanks
          end
          actual = @g.to_open_search_granules(catalog_rest_doc, 1, {:clientId => "foo", :shortName => "MOD02QKM", :versionId => "5", :dataCenter => "LAADS", :cursor => "1", :numberOfResults => "10"}, "#{ENV['opensearch_url']}/granules?cursor=1&numberOfResults=10")
          expect(actual.to_xml(:indent => 2)).to eq(opensearch_doc.to_xml(:indent => 2))
        end
  end

  describe "granule query validation" do
    it "is possible to supply no parameters" do
      params = {}
      granule = Granule.new(params)
      expect(granule.valid?).to eq(true)
    end
    describe "clientId" do
      it "is possible to supply a client id 'foo'" do
        params = {:clientId => 'foo'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(true)
      end

      it "is not possible to supply a client id '###'" do
        params = {:clientId => '###'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
      end
    end

    describe "numberOfResults" do
      it "is possible to supply a numberOfResults of 1" do
        params = {:numberOfResults => 1}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(true)
      end

      it "is possible to supply a numberOfResults of '1'" do
        params = {:numberOfResults => '1'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(true)
      end

      it "is possible to supply a numberOfResults of 2000" do
        params = {:numberOfResults => 2000}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(true)
      end

      it "is not possible to supply a numberOfResults of 1.1" do
        params = {:numberOfResults => 1.1}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
      end

      it "is not possible to supply a numberOfResults of -1" do
        params = {:numberOfResults => -1}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
      end

      it "is not possible to supply a numberOfResults of 0" do
        params = {:numberOfResults => 0}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
      end

      it "is not possible to supply a numberOfResults of 'foo'" do
        params = {:numberOfResults => 'foo'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
      end

      it 'is not possible to supply a numberOfResults greater than 2000' do
        params = {:numberOfResults => 20001}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
      end
    end

    describe "cursor" do
      it "is possible to supply a cursor of 1" do
        params = {:cursor => 1}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(true)
      end

      it "is possible to supply a cursor of '1'" do
        params = {:cursor => '1'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(true)
      end

      it "is possible to supply a cursor of 3" do
        params = {:cursor => 3}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(true)
      end

      it "is not possible to supply a cursor of 1.1" do
        params = {:cursor => 1.1}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
      end

      it "is not possible to supply a cursor of -1" do
        params = {:cursor => -1}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
      end

      it "is not possible to supply a cursor of 0" do
        params = {:cursor => 0}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
      end

      it "is not possible to supply a cursor of 'foo'" do
        params = {:cursor => 'foo'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
      end
    end

    describe "startTime" do
      it "is possible to supply a startTime '2010-01-01T00:00:00Z'" do
        params = {:startTime => '2010-01-01T00:00:00Z'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(true)
      end

      it "is not possible to supply a startTime '###'" do
        params = {:startTime => '###'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
        expect(granule.errors[:startTime]).to eq(['### is not a valid rfc3339 date'])
      end
    end

    describe "endTime" do
      it "is possible to supply a endTime '2010-01-01T00:00:00Z'" do
        params = {:endTime => '2010-01-01T00:00:00Z'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(true)
      end

      it "is not possible to supply a endTime '###'" do
        params = {:endTime => '###'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
        expect(granule.errors[:endTime]).to eq(['### is not a valid rfc3339 date'])
      end
    end

    describe "geometry" do
      it "is possible to supply a geometry 'POINT (1 2)'" do
        params = {:geometry => 'POINT (1 2)'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(true)
      end

      it "is possible to supply a geometry 'LINESTRING (30 10, 10 30, 40 40)'" do
        params = {:geometry => 'LINESTRING (30 10, 10 30, 40 40)'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(true)
      end

      it "is possible to supply a geometry 'POLYGON ((30 10, 10 20, 20 40, 40 40, 30 10))'" do
        params = {:geometry => 'POLYGON ((30 10, 10 20, 20 40, 40 40, 30 10))'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(true)
      end

      it "is not possible to supply a geometry '###'" do
        params = {:geometry => '###'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
        expect(granule.errors[:geometry]).to eq(['### is not a valid WKT'])
      end

      it "is not possible to supply a geometry 'MULTIPOINT (10 40, 40 30, 20 20, 30 10)'" do
        params = {:geometry => 'MULTIPOINT (10 40, 40 30, 20 20, 30 10)'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
        expect(granule.errors[:geometry]).to eq(['MULTIPOINT (10 40, 40 30, 20 20, 30 10) is not supported, please use POINT, LINESTRING or POLYGON'])
      end
    end

    describe "bounding box" do
      it "is possible to supply a boundingBox '-180,-90,180,90'" do
        params = {:boundingBox => '-180,-90,180,90'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(true)
      end
      it "is possible to supply a boundingBox '-180.0,-90.0,180.0,90.0'" do
        params = {:boundingBox => '-180.0,-90.0,180.0,90.0'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(true)
      end
      it "is not possible to supply a boundingBox '-180.0 -90.0 180.0 90.0'" do
        params = {:boundingBox => '-180.0 -90.0 180.0 90.0'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
        expect(granule.errors[:boundingBox]).to eq(['-180.0 -90.0 180.0 90.0 is not a valid boundingBox'])
      end
      it "is not possible to supply a boundingBox '1,2'" do
        params = {:boundingBox => '1,2'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
        expect(granule.errors[:boundingBox]).to eq(['1,2 is not a valid boundingBox'])
      end
      it "is not possible to supply a boundingBox '-181.0,-90.0,180.0,90.0'" do
        params = {:boundingBox => '-181.0,-90.0,180.0,90.0'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
        expect(granule.errors[:boundingBox]).to eq(['-181.0,-90.0,180.0,90.0 is not a valid boundingBox'])
      end
      it "is not possible to supply a boundingBox '-180,-91,180,90'" do
        params = {:boundingBox => '-180,-91,180,90'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
        expect(granule.errors[:boundingBox]).to eq(['-180,-91,180,90 is not a valid boundingBox'])
      end
      it "is not possible to supply a boundingBox '-180,-90,181,90'" do
        params = {:boundingBox => '-180,-90,181,90'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
        expect(granule.errors[:boundingBox]).to eq(['-180,-90,181,90 is not a valid boundingBox'])
      end
      it "is not possible to supply a boundingBox '-180,-90,180,91'" do
        params = {:boundingBox => '-180,-90,180,91'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
        expect(granule.errors[:boundingBox]).to eq(['-180,-90,180,91 is not a valid boundingBox'])
      end
      it "is not possible to supply a boundingBox '###'" do
        params = {:boundingBox => '###'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
        expect(granule.errors[:boundingBox]).to eq(['### is not a valid boundingBox'])
      end
    end

    describe "point and radius" do
      it "is possible to supply a valid point radius" do
        params = {:lat => '56', :lon => '120', :radius => '10000'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(true)
      end
      it "is not possible to miss lat in point radius search" do
        params = {:lon => '120', :radius => '10000'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
        expect(granule.errors[:lat]).to eq(['cannot be empty for point radius search'])
      end
      it "is not possible to miss lon in point radius search" do
        params = {:lat => '56', :radius => '10000'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
        expect(granule.errors[:lon]).to eq(['cannot be empty for point radius search'])
      end
      it "is not possible to miss radius in point radius search" do
        params = {:lat => '56', :lon => '120'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
        expect(granule.errors[:radius]).to eq(['cannot be empty for point radius search'])
      end
      it "is not possible to miss lon and radius in point radius search" do
        params = {:lat => '56'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
        expect(granule.errors[:lon]).to eq(['cannot be empty for point radius search'])
        expect(granule.errors[:radius]).to eq(['cannot be empty for point radius search'])
      end
      it "is not possible to miss lat and radius in point radius search" do
        params = {:lon => '120'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
        expect(granule.errors[:lat]).to eq(['cannot be empty for point radius search'])
        expect(granule.errors[:radius]).to eq(['cannot be empty for point radius search'])
      end
      it "is not possible to miss the point in point radius search" do
        params = {:radius => '10000'}
        granule = Granule.new(params)
        expect(granule.valid?).to eq(false)
        expect(granule.errors[:lat]).to eq(['cannot be empty for point radius search'])
        expect(granule.errors[:lon]).to eq(['cannot be empty for point radius search'])
      end
    end
  end
end
