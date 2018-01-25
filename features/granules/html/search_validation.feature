@granules_search_validation_html
Feature: Retrieve granules in html format
  In order to obtain granules products
  as an open search user
  I should be warned of any errors in my search constraints

  Scenario: Search for granules using invalid spatial bounding box
    Given I have executed a html granule search with the following parameters:
      | input        | value        |
      | spatial_type | Bounding box |
      | boundingBox  | foo          |
    Then I should see 0 granule results
    And I should see 4 error messages
    And I should see "Boundingbox foo is not a valid boundingBox"
    And I should see "A granule search requires the Collection ConceptID or the Collection ShortName or the Granule Unique Identifier"
    And I should see "4 errors prohibited this search from being executed:"

  Scenario: Search for dataset using invalid spatial geometry
    Given I have executed a html granule search with the following parameters:
      | input        | value    |
      | spatial_type | Geometry |
      | geometry     | foo      |
    Then I should see 0 granule results
    And I should see 4 error messages
    And I should see "Geometry foo is not a valid WKT"
    And I should see "A granule search requires the Collection ConceptID or the Collection ShortName or the Granule Unique Identifier"
    And I should see "4 errors prohibited this search from being executed:"

  Scenario: Search for granule using invalid temporal constraints (constraint not in extent)
    Given I have executed a html granule search with the following parameters:
      | input     | value                |
      | startTime | foo                  |
      | endTime   | 1999-02-01T23:00:00Z |
    Then I should see 0 granule results
    And I should see 4 error messages
    And I should see "Starttime foo is not a valid rfc3339 date"
    And I should see "A granule search requires the Collection ConceptID or the Collection ShortName or the Granule Unique Identifier"
    And I should see "4 errors prohibited this search from being executed:"

  Scenario: Search for granule using invalid temporal constraints (constraint not in extent)
    Given I have executed a html granule search with the following parameters:
      | input     | value                |
      | startTime | 1999-02-01T23:00:00Z |
      | endTime   | foo                  |
    Then I should see 0 granule results
    And I should see 4 error messages
    And I should see "Endtime foo is not a valid rfc3339 date"
    And I should see "A granule search requires the Collection ConceptID or the Collection ShortName or the Granule Unique Identifier"
    And I should see "4 errors prohibited this search from being executed:"

  Scenario: Search for granule using invalid paging
    Given I have executed a html collection search with the following parameters:
      | input           | value |
      | numberOfResults | foo   |
      | cursor          | 1     |
    Then I should see 0 granule results
    And I should see 1 error message
    And I should see "Numberofresults is not a number"
    And I should see "1 error prohibited this search from being executed:"
    Given I have executed a html granule search with the following parameters:
      | input           | value |
      | numberOfResults | 2     |
      | cursor          | foo   |
    Then I should see 0 granule results
    And I should see 4 error messages
    And I should see "Cursor is not a number"
    And I should see "A granule search requires the Collection ConceptID or the Collection ShortName or the Granule Unique Identifier"
    And I should see "4 errors prohibited this search from being executed:"

  Scenario: Search for granule using invalid paging with multiple errors
    Given I have executed a html granule search with the following parameters:
      | input           | value |
      | numberOfResults | bar   |
      | cursor          | foo   |
    Then I should see 0 granule results
    And I should see 5 error messages
    And I should see "Cursor is not a number"
    And I should see "Numberofresults is not a number"
    And I should see "A granule search requires the Collection ConceptID or the Collection ShortName or the Granule Unique Identifier"
    And I should see "5 errors prohibited this search from being executed:"

  Scenario: Search for granule using placename
    Given I have executed a html granule search with the following parameters:
      | input        | value      |
      | spatial_type | Place Name |
      | placeName    | dougopolis |
    Then I should see 0 collection results
    And I should see 4 error messages
    And I should see "Placename dougopolis cannot be located"
    And I should see "A granule search requires the Collection ConceptID or the Collection ShortName or the Granule Unique Identifier"
    And I should see "4 errors prohibited this search from being executed:"
