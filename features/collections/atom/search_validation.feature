@datasets_search_validation_atom
Feature: Retrieve collections in atom format
  In order to obtain collection products
  as an open search user
  I should be warned of any errors in my search constraints

  Scenario: Search for collection using invalid spatial bounding box
    Given I have executed a collection search with the following parameters:
      | clientId | boundingBox | keyword    |
      | foo      | foo         | OPENSEARCH |
    Then I should see a valid error response
    And I should see 1 error
    And I should see the error "Boundingbox foo is not a valid boundingBox"

  Scenario: Search for collection using invalid start temporal constraints
    Given I have executed a collection search with the following parameters:
      | clientId | startTime | endTime              | keyword    |
      | foo      | foo       | 1999-02-01T23:00:00Z | OPENSEARCH |
    Then I should see a valid error response
    And I should see 1 error
    And I should see the error "Starttime foo is not a valid rfc3339 date"

  Scenario: Search for collection using invalid end temporal constraints
    Given I have executed a collection search with the following parameters:
      | clientId | startTime            | endTime | keyword    |
      | foo      | 1999-02-01T23:00:00Z | foo     | OPENSEARCH |
    Then I should see a valid error response
    And I should see 1 error
    And I should see the error "Endtime foo is not a valid rfc3339 date"

  Scenario: Search for collection using invalid paging
    Given I have executed a collection search with the following parameters:
      | clientId | numberOfResults | cursor | keyword           |
      | foo      | foo             | 1      | Paging OPENSEARCH |
    Then I should see a valid error response
    And I should see 1 error
    And I should see the error "Numberofresults is not a number"
    And I have executed a collection search with the following parameters:
      | clientId | numberOfResults | cursor | keyword           |
      | foo      | 2               | foo    | Paging OPENSEARCH |
    Then I should see a valid error response
    And I should see 1 error
    And I should see the error "Cursor is not a number"
    And I have executed a collection search with the following parameters:
      | clientId | numberOfResults | cursor | keyword           |
      | foo      | bar             | foo    | Paging OPENSEARCH |
    Then I should see a valid error response
    And I should see 2 errors
    And I should see the error "Numberofresults is not a number"
    And I should see the error "Cursor is not a number"

  Scenario: Search for collection using invalid constraint
      Given I have executed a collection search with the following parameters:
        | clientId | foo |
        | foo      | bar |
      Then I should see a valid collection atom response
      And I should see 10 results
