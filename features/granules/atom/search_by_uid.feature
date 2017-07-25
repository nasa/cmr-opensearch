@granules_search_by_uid_atom
Feature: Retrieve granules in atom format
  In order to obtain granule products
  as an open search user
  I should be able to search for granules using a machine-readable format using a unique id associated with that granule

  Scenario: Search for granule using spatial bounding box
    Given I have executed a granule search with the following parameters:
      | clientId | boundingBox |
      | foo      | -5,-5,5,5   |
    Then I should see a valid granule atom response
    And I should see 1 result
    And I execute a granule search using the unique id associated with result number 1
    And I should see 1 result
    And result 1 should have a the following echo characteristics,
      | producerGranuleId      |
      | SpatialTestingGranule2 |

