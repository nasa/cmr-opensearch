@datasets_search_traversal_atom
Feature: Retrieve collections in atom format and be able to navigate to and from granule results
  In order to obtain granule products
  as an open search user
  I should be able to search for collections (using the atom view) and discover granules from those results

  Scenario: Search for collection without traversal
    Given I have executed a collection search with the following parameters:
      | clientId | keyword      | cursor | numberOfResults |
      | foo      | NonTraversal | 1      | 10             |
    Then I should see a valid collection atom response
    And I should see 1 result
    And result 1 should have a title of "NonTraversal Dataset 1"
    And the result set should have a link to this result
    And the result set should have a link to the last result for a cursor of 1
    And the result set should have a link to the first result
    And the result set should not have a link to the next result
    And the result set should not have a link to the previous result

  Scenario: Search for collection with traversal
    Given I have executed a collection search with the following parameters:
      | clientId | keyword   | cursor | numberOfResults |
      | foo      | Traversal | 1      | 2               |
    Then I should see a valid collection atom response
    And I should see 2 results
    And the result set should have a link to this result
    And the result set should have a link to the last result for a cursor of 2
    And the result set should have a link to the first result
    And the result set should have a link to the next result
    And the result set should not have a link to the previous result
    When I navigate to the next result
    Then I should see a valid collection atom response
    And I should see 1 result
    And the result set should have a link to this result
    And the result set should have a link to the last result for a cursor of 2
    And the result set should have a link to the first result
    And the result set should not have a link to the next result
    And the result set should have a link to the previous result
    When I navigate to the previous result
    Then I should see a valid collection atom response
    And I should see 2 results
    And the result set should have a link to this result
    And the result set should have a link to the next result
    And the result set should not have a link to the previous result

Scenario: Search for collection with traversal empty cursor
    Given I have executed a collection search with the following parameters:
      | clientId | keyword   | cursor | numberOfResults |
      | foo      | Traversal |        | 2               |
    Then I should see a valid collection atom response
    And I should see 2 results
    And the result set should have a link to this result
    And the result set should have a link to the last result for a cursor of 2
    And the result set should have a link to the first result
    And the result set should have a link to the next result
    And the result set should not have a link to the previous result
    When I navigate to the next result
    Then I should see a valid collection atom response
    And I should see 1 result
    And the result set should have a link to this result
    And the result set should have a link to the last result for a cursor of 2
    And the result set should have a link to the first result
    And the result set should not have a link to the next result
    And the result set should have a link to the previous result
    When I navigate to the previous result
    Then I should see a valid collection atom response
    And I should see 2 results
    And the result set should have a link to this result
    And the result set should have a link to the next result
    And the result set should not have a link to the previous result

Scenario: Search for collection with traversal  (NCR 11013952)
    Given I have executed a collection search with the following parameters:
      | clientId | keyword   | numberOfResults |
      | foo      | Traversal | 2               |
    Then I should see a valid collection atom response
    And I should see 2 results
    And the result set should have a link to this result
    And the result set should have a link to the next result
    And the result set should not have a link to the previous result
    And the result set should have a link to the last result for a cursor of 2
    And the result set should have a link to the first result

Scenario: Search for collection with first and last (CWIC-37)
    Given I have executed a collection search with the following parameters:
      | clientId | keyword   | numberOfResults |
      | foo      | LastCursor | 2               |
    Then I should see a valid collection atom response
    And I should see 2 results
    And the result set should have a link to this result
    And the result set should have a link to the next result
    And the result set should not have a link to the previous result
    And the result set should have a link to the last result for a cursor of 4
    And the result set should have a link to the first result
    When I navigate to the next result
    Then I should see a valid collection atom response
    And I should see 2 results
    And the result set should have a link to this result
    And the result set should have a link to the last result for a cursor of 4
    And the result set should have a link to the first result

Scenario: Search for collection with first and last (CWIC-37)
    Given I have executed a collection search with the following parameters:
      | clientId | keyword   | numberOfResults |
      | foo      | LastCursor | 3               |
    Then I should see a valid collection atom response
    And I should see 3 results
    And the result set should have a link to this result
    And the result set should have a link to the next result
    And the result set should not have a link to the previous result
    And the result set should have a link to the last result for a cursor of 3
    And the result set should have a link to the first result
    When I navigate to the next result
    Then I should see a valid collection atom response
    And I should see 3 results
    And the result set should have a link to this result
    And the result set should have a link to the last result for a cursor of 3
    And the result set should have a link to the first result
