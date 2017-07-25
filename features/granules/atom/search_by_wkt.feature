@fixtures
@granules_search_by_wkt_atom
Feature: Retrieve granules in atom format
  In order to obtain granule products
  as an open search user
  I should be able to search for granules using a machine-readable format using a geometry constraint describing AOI in Well-known Text (WKT)

  Scenario: Search for granule using WKT point
    Given I have executed a granule search with the following parameters:
      | clientId | geometry      |
      | foo      | POINT (-5 -5) |
    Then I should see a valid granule atom response
    And I should see 1 result
    And result 1 should have a the following echo characteristics,
      | producerGranuleId      |
      | SpatialTestingGranule2 |
    And I should see a query element with the following characteristics,
      | geo:geometry  |
      | POINT (-5 -5) |

  Scenario: Search for granule using WKT point (no hit)
    Given I have executed a granule search with the following parameters:
      | clientId | geometry      |
      | foo      | POINT (30 30) |
    Then I should see a valid granule atom response
    And I should see 0 results
    And I should see a query element with the following characteristics,
      | geo:geometry  |
      | POINT (30 30) |

  Scenario: Search for granule using WKT line
    Given I have executed a granule search with the following parameters:
      | clientId | geometry              |
      | foo      | LINESTRING (5 5, 4 4) |
    Then I should see a valid granule atom response
    And I should see 1 result
    And result 1 should have a the following echo characteristics,
      | producerGranuleId      |
      | SpatialTestingGranule2 |
    And I should see a query element with the following characteristics,
      | geo:geometry          |
      | LINESTRING (5 5, 4 4) |

  Scenario: Search for granule using WKT line(no hit)
    Given I have executed a granule search with the following parameters:
      | clientId | geometry                  |
      | foo      | LINESTRING (30 30, 35 35) |
    Then I should see a valid granule atom response
    And I should see 0 results
    And I should see a query element with the following characteristics,
      | geo:geometry              |
      | LINESTRING (30 30, 35 35) |

  Scenario: Search for granule using WKT polygon
    Given I have executed a granule search with the following parameters:
      | clientId | geometry                        |
      | foo      | POLYGON ((1 1, -1 2, 1 3, 1 1)) |
    Then I should see a valid granule atom response
    And I should see 1 result
    And result 1 should have a the following echo characteristics,
      | producerGranuleId      |
      | SpatialTestingGranule2 |
    And I should see a query element with the following characteristics,
      | geo:geometry                    |
      | POLYGON ((1 1, -1 2, 1 3, 1 1)) |

  Scenario: Search for granule using WKT polygon (no hit)
    Given I have executed a granule search with the following parameters:
      | clientId | geometry                                      |
      | foo      | POLYGON ((30 10, 10 20, 20 40, 40 40, 30 10)) |
    Then I should see a valid granule atom response
    And I should see 0 results
    And I should see a query element with the following characteristics,
      | geo:geometry                                  |
      | POLYGON ((30 10, 10 20, 20 40, 40 40, 30 10)) |

  Scenario: Search for granule using WKT multi-polygon (not supported)
    Given I have executed a granule search with the following parameters:
      | clientId | geometry                                 | keyword    |
      | foo      | MULTIPOINT ((-180 -90), (0 0), (180 90)) | OPENSEARCH |
    Then I should see a not supported HTTP response
