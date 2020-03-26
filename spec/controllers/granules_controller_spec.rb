require 'spec_helper'
describe GranulesController do
  describe "GET descriptor_document" do
    context "with valid attributes" do
      it "renders a descriptor document" do
        get :descriptor_document, :format => :xml, :params => { :clientId => 'foo', :shortName => 'MOD02QKM', :versionId => '005', :dataCenter => 'LAADS' }
        expect(response).to render_template("granules/descriptor_document")
      end
    end
    context "with invalid attributes" do
      it "renders an error" do
        get :descriptor_document, :format => :xml, :params => { :clientId => '###'}
        expect(response.status).to eq(400)
      end
    end
    context 'with valid and invalid query parameters' do
      it 'renders a descriptor document' do
        get :descriptor_document, :format => :xml, :params => { :clientId => 'foo', :invalid_query_parameter => 'invalid_query_parameter_value' }
        expect(response.status).to eq(200)
        expect(response).to render_template("descriptor_document")
      end
    end
  end

  describe "GET RestClient error" do
    context "with larger than allowed cursor value" do
      it 'is possible to execute an OpenSearch granule query with a larger than allowed cursor and NOT get an internal server error' do
        VCR.use_cassette 'controllers/granules_cursor_too_large', :record => :once do
          get :index, :format => :atom, :params => { :clientId => 'foo', :datasetId => 'MODIS/Terra+Aqua Leaf Area Index/FPAR 8-Day L4 Global 1km SIN Grid V005', :cursor => '174558594' }
          assert_equal "400", response.code
          assert_equal "<?xml version=\"1.0\" encoding=\"UTF-8\"?><errors><error>The paging depth (page_num * page_size) of [1745585940] exceeds the limit of 1000000.</error></errors>", response.body
        end
      end
    end
  end

  describe "GET granules" do
    context "without specifying the collection short name or concept ID" do
      it 'is possible to execute an OpenSearch granule GET query without specifying the required search form parameters' do
        VCR.use_cassette 'controllers/granules_api_search_without_form_params', :record => :once, :decode_compressed_response => true do
          get :index, :format => :atom, :params => { :clientId => 'foo' }
          assert_equal "200", response.code
          # verify that response has 10 entries
          response_doc = Nokogiri::XML(response.body)
          num_feed_entries = response_doc.xpath('//atom:feed/atom:entry', 'atom' => 'http://www.w3.org/2005/Atom').size
          expect(num_feed_entries).to eq(10)
        end
      end
    end
  end

end
