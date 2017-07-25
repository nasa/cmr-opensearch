@datasets_search_geoss_atom
Feature: Retrieve collections in atom format with geoss element
  In order to obtain collection products
  as an open search user
  I should be able to search for geoss collections using a machine-readable format

  Scenario: Search for collection using keyword
    Given I have executed a collection search with the following parameters:
      | clientId | keyword   |
      | foo      | GEOS_TEST |
    Then I should see a valid collection atom response
    And I should see an open search query node in the results corresponding to:
      | os:searchTerms  |
      | GEOS_TEST       |
    Then I should see 2 results
    And result 1 should have a geoss tag
    And result 2 should not have a geoss tag

