@granules_search_validation_atom
Feature: Retrieve granules in atom format
  In order to obtain granule products
  as an open search user
  I should be warned of any errors in my search constraints

  Scenario: Search for granule using invalid spatial bounding box
    Given I have executed a granule search with the following parameters:
      | clientId | boundingBox |
      | foo      | foo         |
    Then I should see a valid error response
    And I should see 1 error
    And I should see the error "Boundingbox foo is not a valid boundingBox"

  Scenario: Search for granule using invalid start temporal constraints
    Given I have executed a granule search with the following parameters:
      | clientId | startTime | endTime              |
      | foo      | foo       | 1999-02-01T23:00:00Z |
    Then I should see a valid error response
    And I should see 1 error
    And I should see the error "Starttime foo is not a valid rfc3339 date"

  Scenario: Search for granule using invalid end temporal constraints
    Given I have executed a granule search with the following parameters:
      | clientId | startTime            | endTime |
      | foo      | 1999-02-01T23:00:00Z | foo     |
    Then I should see a valid error response
    And I should see 1 error
    And I should see the error "Endtime foo is not a valid rfc3339 date"

  Scenario: Search for granule using invalid paging
    Given I have executed a granule search with the following parameters:
      | clientId | numberOfResults | cursor |
      | foo      | foo             | 1      |
    Then I should see a valid error response
    And I should see 1 error
    And I should see the error "Numberofresults is not a number"
    And I have executed a granule search with the following parameters:
      | clientId | numberOfResults | cursor |
      | foo      | 2               | foo    |
    Then I should see a valid error response
    And I should see 1 error
    And I should see the error "Cursor is not a number"
    And I have executed a granule search with the following parameters:
      | clientId | numberOfResults | cursor |
      | foo      | bar             | foo    |
    Then I should see a valid error response
    And I should see 2 errors
    And I should see the error "Numberofresults is not a number"
    And I should see the error "Cursor is not a number"

  Scenario: Search for granule using invalid constraint
    Given I have executed a granule search with the following parameters:
      | clientId | foo |
      | foo      | bar |
    Then I should see a valid granule atom response
    And I should see 10 results

