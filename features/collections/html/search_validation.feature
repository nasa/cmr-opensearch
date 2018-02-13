@datasets_search_validation_html
Feature: Retrieve collections in html format
  In order to obtain collection products
  as an open search user
  I should be warned of any errors in my search constraints

  Scenario: Search for collection using invalid spatial bounding box
    Given I have executed a html collection search with the following parameters:
      | input        | value        |
      | spatial_type | Bounding box |
      | boundingBox  | foo          |
      | keyword      | OPENSEARCH   |
    Then I should see 0 collection results
    And I should see 1 error message
    And I should see "Boundingbox foo is not a valid boundingBox"
    And I should see "1 error prohibited this search from being executed:"

  Scenario: Search for collection using invalid spatial geometry
    Given I have executed a html collection search with the following parameters:
      | input        | value      |
      | spatial_type | Geometry   |
      | geometry     | foo        |
      | keyword      | OPENSEARCH |
    Then I should see 0 collection results
    And I should see 1 error message
    And I should see "Geometry foo is not a valid WKT"
    And I should see "1 error prohibited this search from being executed:"

  Scenario: Search for collection using invalid temporal constraints (constraint not in extent)
    Given I have executed a html collection search with the following parameters:
      | input     | value                |
      | startTime | foo                  |
      | endTime   | 1999-02-01T23:00:00Z |
      | keyword   | OPENSEARCH           |
    Then I should see 0 collection results
    And I should see 1 error message
    And I should see "Starttime foo is not a valid rfc3339 date"
    And I should see "1 error prohibited this search from being executed:"

  Scenario: Search for collection using invalid temporal constraints (constraint not in extent)
    Given I have executed a html collection search with the following parameters:
      | input     | value                |
      | startTime | 1999-02-01T23:00:00Z |
      | endTime   | foo                  |
      | keyword   | OPENSEARCH           |
    Then I should see 0 collection results
    And I should see 1 error message
    And I should see "Endtime foo is not a valid rfc3339 date"
    And I should see "1 error prohibited this search from being executed:"

  Scenario: Search for collection using invalid paging
    Given I have executed a html collection search with the following parameters:
      | input           | value             |
      | numberOfResults | foo               |
      | cursor          | 1                 |
      | keyword         | Paging OPENSEARCH |
    Then I should see 0 collection results
    And I should see 1 error message
    And I should see "Numberofresults is not a number"
    And I should see "1 error prohibited this search from being executed:"
    Given I have executed a html collection search with the following parameters:
      | input           | value             |
      | numberOfResults | 2                 |
      | cursor          | foo               |
      | keyword         | Paging OPENSEARCH |
    Then I should see 0 collection results
    And I should see 1 error message
    And I should see "Cursor is not a number"
    And I should see "1 error prohibited this search from being executed:"

  Scenario: Search for collection using invalid paging with multiple errors
    Given I have executed a html collection search with the following parameters:
      | input           | value             |
      | numberOfResults | bar               |
      | cursor          | foo               |
      | keyword         | Paging OPENSEARCH |
    Then I should see 0 collection results
    And I should see 2 error messages
    And I should see "Cursor is not a number"
    And I should see "Numberofresults is not a number"
    And I should see "2 errors prohibited this search from being executed:"


