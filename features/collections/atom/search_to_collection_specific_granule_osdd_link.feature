@datasets_search_collection_specific_granule_osdd
Feature: Retrieve collections in atom format with collection specific granule osdd link
  In order to obtain collection products
  as an open search user
  I should be able to search for collections using a machine-readable format

  Scenario: Search for collection using keyword
    Given I have executed a collection search with the following parameters:
      | clientId | keyword              |
      | foo      | C1200382883-CMR_ONLY |
    Then I should see 1 result
    And result 1 should have a link to a granule open search descriptor document
    And result 1 should have a link href of 'http://osdd.org/data/amsre/someopensearchdescription.xml' for the granule open search descriptor document
