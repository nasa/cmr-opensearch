@datasets_search_dc_temporal_atom
Feature: Retrieve collections in atom format with dublin core temporal extents
  In order to obtain collection products
  as an open search user
  I should be able to search for collections using a machine-readable format that renders temporal extents compliant with the dublin-core (http://purl.org/dc/elements/1.1/) date element
  # Example: <dc:date xmlns:dc="http://purl.org/dc/elements/1.1/">2010-04- 13T20:38:16.000Z/2010-04-13T20:40:00.000Z</dc:date>

  Scenario: Search for collection with date range
    Given I have executed a collection search with the following parameters:
      | clientId | keyword                   |
      | foo      | Dublin Core range dataset |
    Then I should see a valid collection atom response
    And result 1 should have a dublin core temporal extent of "1951-01-01T00:00:00Z/1952-12-01T00:00:00Z"
    And result 1 should not have an open search time temporal extent

  Scenario: Search for collection with date start
    Given I have executed a collection search with the following parameters:
      | clientId | keyword                   |
      | foo      | Dublin Core start dataset |
    Then I should see a valid collection atom response
    And result 1 should have a dublin core temporal extent of "1953-01-01T00:00:00Z/"
    And result 1 should not have an open search time temporal extent

  Scenario: Search for collection with date end
    Given I have executed a collection search with the following parameters:
      | clientId | keyword                    |
      | foo      | Dublin Core single dataset |
    Then I should see a valid collection atom response
    And result 1 should have a dublin core temporal extent of "1955-01-01T22:00:00Z"
    And result 1 should not have an open search time temporal extent

  Scenario: Search for collection with no temporal extent
    Given I have executed a collection search with the following parameters:
      | clientId | keyword                  |
      | foo      | Dublin Core none dataset |
    Then I should see a valid collection atom response
    And result 1 should have no dublin core temporal extent
