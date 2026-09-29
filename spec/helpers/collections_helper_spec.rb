require 'spec_helper'

describe CollectionsHelper do
  Link = Struct.new(:href, :title)

  describe 'truncate_link' do
    it 'should render a benign link unchanged' do
      markup = truncate_link(Link.new('https://example.gov/data', 'Data set'))

      expect(markup).to eq("<a target='_blank' class='ext' href='https://example.gov/data' title='Data set'>Data set</a>")
    end

    it 'should escape a quote in the href' do
      markup = truncate_link(Link.new("' onmouseover='alert(1)", 'Data set'))

      expect(markup).not_to include("' onmouseover=")
      expect(markup).to include('&#39; onmouseover=&#39;alert(1)')
    end

    it 'should escape markup in the title' do
      markup = truncate_link(Link.new('https://example.gov/data', "'><script>alert(1)</script>"))

      expect(markup).not_to include('<script>')
      expect(markup).to include('&lt;script&gt;')
    end
  end
end
