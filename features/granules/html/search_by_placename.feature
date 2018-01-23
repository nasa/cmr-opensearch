@granules_search_by_placename_html
Feature: Retrieve granules in html format
  In order to obtain granule products
  as an open search user
  I should be able to specify a place name as spatial search constraint

  Scenario: Search for granule using placename
    Given I have executed a html granule search with the following parameters:
      | input        | value             |
      | spatial_type | Place Name        |
      | placeName    | Bowness-on-Solway |
      | shortName    | SampleShortName   |
    Then I should see 1 granule result
    And granule result 1 should have a the following echo characteristics,
      | characteristic | value                  |
      | granule_ur     | BownessOnSolwayGranule |
