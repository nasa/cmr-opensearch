@granules_search_traversal_atom
Feature: Retrieve granules in atom format and be able to navigate to and from granule results
  In order to obtain granule products
  as an open search user
  I should be able to search for granules (using the atom view) and discover granules from those results

  Scenario: Search for granules no traversal
    Given I have executed a granule search with the following parameters:
      | clientId | shortName                  |
      | foo      | NoTraversalGranuleTesting1 |
    Then I should see a valid granule atom response
    And I should see 1 result
    And result 1 should have a title of "NoTraversalGranuleTesting1"
    And the result set should have a link to this result
    And the result set should have a link to the last result for a cursor of 1
    And the result set should have a link to the first result
    And the result set should not have a link to the next result
    And the result set should not have a link to the previous result

  Scenario: Search for granules with traversal
    Given I have executed a granule search with the following parameters:
      | clientId | shortName                | cursor | numberOfResults |
      | foo      | TraversalGranuleTesting1 | 1      | 2               |
    Then I should see a valid granule atom response
    And I should see 2 results
    And the result set should have a link to this result
    And the result set should have a link to the last result for a cursor of 2
    And the result set should have a link to the first result
    And the result set should have a link to the next result
    And the result set should not have a link to the previous result
    When I navigate to the next result
    Then I should see a valid granule atom response
    And I should see 1 result
    And the result set should have a link to this result
    And the result set should have a link to the last result for a cursor of 2
    And the result set should have a link to the first result
    And the result set should not have a link to the next result
    And the result set should have a link to the previous result
    When I navigate to the previous result
    Then I should see a valid granule atom response
    And I should see 2 results
    And the result set should have a link to this result
    And the result set should have a link to the next result
    And the result set should not have a link to the previous result

  Scenario: Search for granules with traversal
     Given I have executed a granule search with the following parameters:
       | clientId | shortName                | cursor | numberOfResults |
       | foo      | TraversalGranuleTesting1 |        | 2               |
     Then I should see a valid granule atom response
     And I should see 2 results
     And the result set should have a link to this result
     And the result set should have a link to the last result for a cursor of 2
     And the result set should have a link to the first result
     And the result set should have a link to the next result
     And the result set should not have a link to the previous result
     When I navigate to the next result
     Then I should see a valid granule atom response
     And I should see 1 result
     And the result set should have a link to this result
     And the result set should have a link to the last result for a cursor of 2
     And the result set should have a link to the first result
     And the result set should not have a link to the next result
     And the result set should have a link to the previous result
     When I navigate to the previous result
     Then I should see a valid granule atom response
     And I should see 2 results
     And the result set should have a link to this result
     And the result set should have a link to the next result
     And the result set should not have a link to the previous result

  Scenario: Search for granules with traversal
      Given I have executed a granule search with the following parameters:
        | clientId | shortName          | numberOfResults |
        | foo      | LastCursorDataset1 | 3               |
      Then I should see a valid granule atom response
      And I should see 3 results
      And the result set should have a link to this result
      And the result set should have a link to the last result for a cursor of 3
      And the result set should have a link to the first result
      And the result set should have a link to the next result
      And the result set should not have a link to the previous result
      When I navigate to the next result
      Then I should see a valid granule atom response
      And I should see 3 results
      And the result set should have a link to this result
      And the result set should have a link to the last result for a cursor of 3
      And the result set should have a link to the first result
      And the result set should have a link to the next result
      And the result set should have a link to the previous result
      When I navigate to the next result
      Then I should see a valid granule atom response
      And I should see 1 result
      And the result set should have a link to this result
      And the result set should have a link to the last result for a cursor of 3
      And the result set should have a link to the first result
      And the result set should not have a link to the next result
      And the result set should have a link to the previous result
      When I navigate to the previous result
      Then I should see a valid granule atom response
      And I should see 3 results
      And the result set should have a link to this result
      And the result set should have a link to the next result
      And the result set should have a link to the previous result
