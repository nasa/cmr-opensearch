@datasets_search_by_geoss_only_atom
Feature: Retrieve collections in atom format that are GEOSS collections
  In order to obtain collection products
  as an open search user
  I should be able to search for collections using a machine-readable format that are GEOSS collections

  Scenario: Search for collection from GEOSS
    Given I have executed a collection search with the following parameters:
      | clientId | isGeoss |
      | foo      | true    |
    Then I should see a valid collection atom response
    And I should see 2 results

  Scenario: Search for collection
    Given I have executed a collection search with the following parameters:
      | clientId | isGeoss |
      | foo      |         |
    Then I should see a valid collection atom response
    And I should see 3 results

