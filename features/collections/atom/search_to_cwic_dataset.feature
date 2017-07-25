@datasets_search_cwic_atom
Feature: Retrieve collections in atom format with CWIC links
  In order to obtain collection products
  as an open search user
  I should be able to search for collections using a machine-readable format

  Scenario: Search for collection using keyword
    Given I have executed a collection search with the following parameters:
      | clientId | keyword  |
      | foo      | GCMDTEST |
    Then I should see a valid collection atom response
    And I should see an open search query node in the results corresponding to:
      | os:searchTerms |
      | GCMDTEST       |
    Then I should see 10 results
    And result 1 should not have a link to a granule search
    And result 1 should have a link to a granule open search descriptor document
    And result 1 should have a link href of 'http://cwictest.wgiss.ceos.org/opensearch/datasets/C1200018718-GCMDTEST/osdd.xml?clientId=foo' for the granule open search descriptor document
    And result 2 should have a link to a granule open search descriptor document
    And result 2 should have a link href of 'http://cwictest.wgiss.ceos.org/opensearch/datasets/C1200018712-GCMDTEST/osdd.xml?clientId=foo' for the granule open search descriptor document
    And result 3 should not have a link to a granule search
    And result 3 should not have a link to a granule open search descriptor document
