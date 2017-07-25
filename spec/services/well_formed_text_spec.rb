require 'spec_helper'

describe WellFormedText do

  describe "point conversion" do
    it "should convert a well formed text of type point to an echo point parameter" do
      echo_params = {}
      echo_params = WellFormedText.add_cmr_param(echo_params, "POINT (1 2)")
      expect(echo_params[:point]).to eq("1.0,2.0")
    end
  end
  describe "line conversion" do
    it "should convert a well formed text of type line to an echo line parameter" do
      echo_params = {}
      echo_params = WellFormedText.add_cmr_param(echo_params, "LINESTRING (30 10, 10 30, 40 40)")
      expect(echo_params[:line]).to eq("30.0,10.0,10.0,30.0,40.0,40.0")
    end
  end
  describe "polygon conversion" do
    it "should convert a well formed text of type polygon to an echo polygon parameter" do
      echo_params = {}
      echo_params = WellFormedText.add_cmr_param(echo_params, "POLYGON ((30 10, 10 20, 20 40, 40 40, 30 10))")
      expect(echo_params[:polygon]).to eq("30.0,10.0,40.0,40.0,20.0,40.0,10.0,20.0,30.0,10.0")
    end
    it "should convert a well formed text of type polygon to an echo polygon parameter" do
      echo_params = {}
      echo_params = WellFormedText.add_cmr_param(echo_params, "POLYGON ((1 1, -1 2, 1 3, 1 1))")
      expect(echo_params[:polygon]).to eq("1.0,1.0,1.0,3.0,-1.0,2.0,1.0,1.0")
    end
  end
end