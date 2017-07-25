@granules_search_by_placename_atom
Feature: Retrieve granules in atom format
  In order to obtain granule products
  as an open search user
  I should be able to specify a place name as spatial search constraint

  Scenario: Search for granule using placename
    Given I have executed a granule search with the following parameters:
      | clientId | placeName         |
      | foo      | Bowness-on-Solway |
    Then I should see a valid granule atom response
    And I should see 1 result
    And result 1 should have a the following echo characteristics,
      | producerGranuleId      |
      | BownessOnSolwayGranule |

  Scenario: Search for granule using invalid placename
    Given I have executed a granule search with the following parameters:
      | clientId | placeName  |
      | foo      | dougopolis |
    Then I should see a valid error response
    And I should see 1 error
    And I should see the error "Placename dougopolis cannot be located"