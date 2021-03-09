@granules_search_dc_temporal_atom
Feature: Retrieve granules in atom format with dublin core temporal extents
  In order to obtain granule products
  as an open search user
  I should be able to search for granules using a machine-readable format that renders temporal extents compliant with the dublin-core (http://purl.org/dc/elements/1.1/) date element
  # Example: <dc:date xmlns:dc="http://purl.org/dc/elements/1.1/">2010-04- 13T20:38:16.000Z/2010-04-13T20:40:00.000Z</dc:date>

  Scenario: Search for granule with date range
    Given I have executed a granule search with the following parameters:
      | clientId | startTime            | endTime              | dataCenter |
      | foo      | 1951-01-01T00:00:00Z | 1952-12-01T00:00:00Z | OS_PROV_2  |
    Then I should see a valid granule atom response
    And result 1 should have a dublin core temporal extent of "1951-01-01T00:00:00Z/1952-12-01T00:00:00Z"
    And result 1 should not have an open search time temporal extent

  Scenario: Search for dataset with date start
    Given I have executed a granule search with the following parameters:
      | clientId | startTime            | endTime              | dataCenter |
      | foo      | 1953-01-01T00:00:00Z | 1954-01-01T00:00:00Z | OS_PROV_2  |
    Then I should see a valid granule atom response
    And result 1 should have a dublin core temporal extent of "1953-01-01T00:00:00Z/"
    And result 1 should not have an open search time temporal extent

  Scenario: Search for dataset with date single
    Given I have executed a granule search with the following parameters:
      | clientId | startTime            | endTime              | dataCenter |
      | foo      | 1945-01-01T22:00:00Z | 1945-02-01T22:00:00Z | OS_PROV_2  |
    Then I should see a valid granule atom response
    And result 1 should have a dublin core temporal extent of "1945-01-01T22:00:00Z"
    And result 1 should not have an open search time temporal extent
