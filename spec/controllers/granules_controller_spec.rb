require 'spec_helper'
describe GranulesController do
  describe "GET descriptor_document" do
    context "with valid attributes" do
      it "renders a descriptor document" do
        get :descriptor_document, :format => :xml, :params => { :clientId => 'foo', :shortName => 'MOD02QKM', :versionId => '005', :dataCenter => 'LAADS' }
        expect(response).to render_template("granules/descriptor_document")
      end
      it "renders a descriptor document" do
        get :descriptor_document, :format => :xml, :params => { :clientId => '', :shortName => 'MOD02QKM', :versionId => '005', :dataCenter => 'LAADS' }
        expect(response).to render_template("granules/descriptor_document")
      end
      it "renders a descriptor document" do
        get :descriptor_document, :format => :xml, :params => { :shortName => 'MOD02QKM', :versionId => '005', :dataCenter => 'LAADS' }
        expect(response).to render_template("granules/descriptor_document")
      end
    end
    context "with invalid attributes" do
      it "renders an error" do
        VCR.use_cassette 'controllers/granules/graphql/C1231649308-ISRO', :record => :once do
          get :descriptor_document, :format => :xml, :params => { :clientId => '###'}
          expect(response.status).to eq(400)
        end
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
  context "with valid collection concept id" do
    it "renders a descriptor document" do
      VCR.use_cassette 'controllers/granules/graphql/C1231649308-ISRO', :record => :once do
        get :descriptor_document, :format => :xml, :params => { :clientId => 'foo', :collectionConceptId => 'C1231649308-ISRO' }
        expect(response).to render_template("granules/mosdac.xml.erb")
      end
    end
  end
  context "with invalid collection concept id" do
    it "renders an error" do
      VCR.use_cassette 'controllers/granules/graphql/invalid', :record => :once do
        get :descriptor_document, :format => :xml, :params => { :clientId => '', :collectionConceptId => 'invalid' }
        expect(response.status).to eq(400)
      end
    end
  end
  context "with a blank clientId" do
    # These test need to have GraphQL recordings but these providers do not have updated metdata
    # that would allow the tests to pass. If/when these providers decide to update their metadata
    # uncomment these tests, but its not really necessary because the clientId functionality isnt
    # unique to any provider
    # it "renders a ccmeo OSDD" do
    #   get :descriptor_document, :format => :xml, :params => { :clientId => '', :collectionConceptId => 'C1214603059-SCIOPS' }
    #   expect(response.status).to eq(200)
    #   expect(response).to render_template("granules/ccmeo.xml.erb")
    # end
    # it "renders an eumetsat OSDD" do
    #   get :descriptor_document, :format => :xml, :params => { :clientId => '', :collectionConceptId => 'C1588876552-EUMETSAT' }
    #   expect(response.status).to eq(200)
    #   expect(response).to render_template("granules/eumetsat.xml.erb")
    # end
    it "renders an nrsc OSDD" do
      VCR.use_cassette 'controllers/granules/graphql/C1443228137-ISRO', :record => :once do
        get :descriptor_document, :format => :xml, :params => { :clientId => '', :collectionConceptId => 'C1443228137-ISRO' }
        expect(response.status).to eq(200)
        expect(response).to render_template("granules/nrsc.xml.erb")
      end
    end
    it "renders a usgslsi OSDD" do
      VCR.use_cassette 'controllers/granules/graphql/C1220566843-USGS_LTA', :record => :once do
        get :descriptor_document, :format => :xml, :params => { :clientId => '', :collectionConceptId => 'C1220566843-USGS_LTA' }
        expect(response.status).to eq(200)
        expect(response).to render_template("granules/usgslsi.xml.erb")
      end
    end
  end

  context "with a whitespace clientId" do
    # These test need to have GraphQL recordings but these providers do not have updated metdata
    # that would allow the tests to pass. If/when these providers decide to update their metadata
    # uncomment these tests, but its not really necessary because the clientId functionality isnt
    # unique to any provider
    # it "renders a ccmeo OSDD" do
    #   get :descriptor_document, :format => :xml, :params => { :clientId => ' ', :collectionConceptId => 'C1214603059-SCIOPS' }
    #   expect(response.status).to eq(200)
    #   expect(response).to render_template("granules/ccmeo.xml.erb")
    # end
    # it "renders an eumetsat OSDD" do
    #   get :descriptor_document, :format => :xml, :params => { :clientId => ' ', :collectionConceptId => 'C1588876552-EUMETSAT' }
    #   expect(response.status).to eq(200)
    #   expect(response).to render_template("granules/eumetsat.xml.erb")
    # end
    it "renders an nrsc OSDD" do
      VCR.use_cassette 'controllers/granules/graphql/C1443228137-ISRO', :record => :once do
        get :descriptor_document, :format => :xml, :params => { :clientId => ' ', :collectionConceptId => 'C1443228137-ISRO' }
        expect(response.status).to eq(200)
        expect(response).to render_template("granules/nrsc.xml.erb")
      end
    end
    it "renders a usgslsi OSDD" do
      VCR.use_cassette 'controllers/granules/graphql/C1220566843-USGS_LTA', :record => :once do
        get :descriptor_document, :format => :xml, :params => { :clientId => ' ', :collectionConceptId => 'C1220566843-USGS_LTA' }
        expect(response.status).to eq(200)
        expect(response).to render_template("granules/usgslsi.xml.erb")
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
