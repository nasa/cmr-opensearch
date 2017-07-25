@datasets_search_by_granules_only_atom
Feature: Retrieve collections in atom format that have granules
  In order to obtain collection products
  as an open search user
  I should be able to search for collections using a machine-readable format that have granules

  Scenario: Search for collection with granules
    Given I have executed a collection search with the following parameters:
      | clientId | hasGranules |
      | foo      | true         |
    Then I should see a valid collection atom response
    And I should see 2 results

  Scenario: Search for collection without granules
    Given I have executed a collection search with the following parameters:
      | clientId | hasGranules |
      | foo      | false        |
    Then I should see a valid collection atom response
    And I should see 1 result

  Scenario: Search for collection without either
    Given I have executed a collection search with the following parameters:
      | clientId | hasGranules |
      | foo      |             |
    Then I should see a valid collection atom response
    And I should see 3 results

