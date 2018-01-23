@granules_search_by_uid_html
Feature: Retrieve granules in atom format
  In order to obtain granule products
  as an open search user
  I should be able to search for granules using a machine-readable format using a unique id associated with that granule

  Scenario: Search for granule using spatial bounding box
    Given I have executed a html granule search with the following parameters:
      | input       | value     |
      | boundingBox | -5,-5,5,5 |
      | shortName | SampleShortName |
    Then I should see 1 granule result
    And I execute a html granule search using the unique id associated with result number 1
    Then I should see 1 granule result
    And granule result 1 should have a the following echo characteristics,
      | characteristic         | value        |
      | granule_ur             | SpatialTestingGranule2 |

