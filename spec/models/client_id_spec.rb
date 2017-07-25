require 'spec_helper'

describe ClientId do
  describe "client id" do
    it "is possible to create a client id 'foo'" do
      c = ClientId.new({:clientId => 'foo'})

      expect(c.valid?).to eq(true)
    end

    it "is possible to create a client id 'aw3'" do
      c = ClientId.new({:clientId => 'aw3'})

      expect(c.valid?).to eq(true)
    end

    it "is not possible to create a client id '###'" do
      c = ClientId.new({:clientId => '###'})
      expect(c.valid?).to eq(false)
    end
  end
end