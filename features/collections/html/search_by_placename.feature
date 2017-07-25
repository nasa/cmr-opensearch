@datasets_search_by_placename_html
Feature: Retrieve collections in html format
  In order to obtain granule products
  as an open search user
  I should be able to specify a place name as spatial search constraint

  Scenario: Search for collection using placename
    Given I have executed a html collection search with the following parameters:
      | input        | value             |
      | spatial_type | Place Name        |
      | placeName    | Bowness-on-Solway |
    Then I should see 1 collection result
    And collection result 1 should have a the following echo characteristics,
      | characteristic | value                  |
      | short_name     | BownessOnSolwayDataset |
