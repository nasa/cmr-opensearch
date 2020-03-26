require 'spec_helper'
describe CollectionsController do
  describe 'GET descriptor_document' do
    context 'with valid attributes' do
      it 'renders a descriptor document' do
        get :descriptor_document, :format => :xml, :params => { :clientId => 'foo' }
        expect(response).to render_template("descriptor_document")
      end
    end
    context 'with invalid attributes' do
      it 'renders an error' do
        get :descriptor_document, :format => :xml, :params => { :clientId => '###' }
        expect(response.status).to eq(400)
      end
    end
    context 'with valid and invalid query parameters' do
      it 'renders a descriptor document' do
        request.env['clientId'] = 'foo'
        get :descriptor_document, :format => :xml, :params => { :clientId => 'foo', :invalid_query_parameter => 'invalid_query_parameter_value' }
        expect(response.status).to eq(200)
        expect(response).to render_template("descriptor_document")
      end
    end
    context 'with invalid attributes' do
      it 'renders an error' do
        get :descriptor_document, :format => :xml, :params => { :clientId => '###' }
        expect(response.status).to eq(400)
      end
    end
  end

  describe 'GET descriptor_document facets' do
    context 'with valid attributes' do
      it 'renders the facet-enabled descriptor document' do
        get :descriptor_document_facets, :format => :xml, :params => { :clientId => 'foo' }
        expect(response).to render_template("descriptor_document_facets")
      end
    end
    context 'with invalid attributes' do
      it 'renders an error' do
        get :descriptor_document_facets, :format => :xml, :params => { :clientId => '###' }
        expect(response.status).to eq(400)
      end
    end
    context 'with valid and invalid query parameters' do
      it 'renders the facet-enabled descriptor document' do
        get :descriptor_document_facets, :format => :xml, :params => { :clientId => 'foo', :invalid_query_parameter => 'invalid_query_parameter_value' }
        expect(response.status).to eq(200)
        expect(response).to render_template("descriptor_document_facets")
      end
    end
  end

  describe 'GET RestClient error' do
    context 'with larger than allowed cursor value' do
      it 'is possible to execute an OpenSearch dataset query with a larger than allowed cursor and NOT get an internal server error' do
        VCR.use_cassette 'controllers/datasets_cursor_too_large', :record => :once do
          get :index, :format => :atom, :params => { :clientId => 'foo', :cursor => '174558594' }
          assert_equal '400', response.code
          assert_equal '<?xml version="1.0" encoding="UTF-8"?><errors><error>The paging depth (page_num * page_size) of [1745585940] exceeds the limit of 1000000.</error></errors>', response.body
        end
      end
    end
  end
end
