require 'spec_helper'

describe 'shared/pagination' do
  let(:model) { Collection.new(keyword: 'test', hasGranules: 'true') }

  before do
    assign(:collection, model)
  end

  it 'preserves hasGranules in next page link' do
    render partial: 'shared/pagination', locals: {
      cursor: 1,
      number_of_results: 10,
      length: 10,
      number_of_hits: 100,
      parent: false,
      model: model,
      spatial_type: nil,
      position: 'top'
    }

    expect(rendered).to have_link(href: /hasGranules=true/)
  end

  it 'preserves hasGranules in previous page link' do
    render partial: 'shared/pagination', locals: {
      cursor: 2,
      number_of_results: 10,
      length: 10,
      number_of_hits: 100,
      parent: false,
      model: model,
      spatial_type: nil,
      position: 'top'
    }

    expect(rendered).to have_link(href: /hasGranules=true/)
  end
end
