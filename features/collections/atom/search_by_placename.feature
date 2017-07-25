@datasets_search_by_placename_atom
Feature: Retrieve collections in atom format
  In order to obtain granule products
  as an open search user
  I should be able to specify a place name as spatial search constraint

  Scenario: Search for collection using placename
    Given I have executed a collection search with the following parameters:
      | clientId | placeName         |
      | foo      | Bowness-on-Solway |
    Then I should see a valid collection atom response
    And I should see 1 result
    And result 1 should have a the following echo characteristics,
      | shortName              |
      | BownessOnSolwayDataset |

  Scenario: Search for collection using invalid placename
    Given I have executed a collection search with the following parameters:
      | clientId | placeName  |
      | foo      | dougopolis |
    Then I should see a valid error response
    And I should see 1 error
    And I should see the error "Placename dougopolis cannot be located"