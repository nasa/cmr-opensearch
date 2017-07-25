@datasets_search_by_wkt_atom
Feature: Retrieve collections in atom format
  In order to obtain collection products
  as an open search user
  I should be able to search for collections using a machine-readable format using a geometry constraint describing Area Of Interest in Well-known Text (WKT)

  Scenario: Search for collection using WKT point
    Given I have executed a collection search with the following parameters:
      | clientId | geometry      | keyword    |
      | foo      | POINT (-5 -5) | OPENSEARCH |
    Then I should see a valid collection atom response
    And I should see 1 result
    And result 1 should have a the following echo characteristics,
      | shortName              | versionId | datasetId                        | dataCenter |
      | SpatialTestingDataset1 | 1         | Spatial Testing dataset number 1 | OS_PROV_1  |
    And result 1 should have a description of "Spatial test 1 - OPENSEARCH"
    And result 1 should not have a link to a granule search
    And result 1 should not have a link to a granule open search descriptor document
    And I should see a query element with the following characteristics,
      | geo:geometry  |
      | POINT (-5 -5) |

  Scenario: Search for collection using WKT point (no hit)
    Given I have executed a collection search with the following parameters:
      | clientId | geometry      | keyword    |
      | foo      | POINT (30 30) | OPENSEARCH |
    Then I should see a valid collection atom response
    And I should see 0 results
    And I should see a query element with the following characteristics,
      | geo:geometry  |
      | POINT (30 30) |

  Scenario: Search for collection using WKT line
    Given I have executed a collection search with the following parameters:
      | clientId | geometry              | keyword    |
      | foo      | LINESTRING (5 5, 4 4) | OPENSEARCH |
    Then I should see a valid collection atom response
    And I should see 1 result
    And result 1 should have a the following echo characteristics,
      | shortName              | versionId | datasetId                        | dataCenter |
      | SpatialTestingDataset1 | 1         | Spatial Testing dataset number 1 | OS_PROV_1  |
    And result 1 should have a description of "Spatial test 1 - OPENSEARCH"
    And result 1 should not have a link to a granule search
    And result 1 should not have a link to a granule open search descriptor document
    And I should see a query element with the following characteristics,
      | geo:geometry          |
      | LINESTRING (5 5, 4 4) |

  Scenario: Search for collection using WKT line (no hit)
    Given I have executed a collection search with the following parameters:
      | clientId | geometry                  | keyword    |
      | foo      | LINESTRING (30 30, 35 35) | OPENSEARCH |
    Then I should see a valid collection atom response
    And I should see 0 results
    And I should see a query element with the following characteristics,
      | geo:geometry              |
      | LINESTRING (30 30, 35 35) |

  Scenario: Search for collection using WKT polygon
    Given I have executed a collection search with the following parameters:
      | clientId | geometry                        | keyword    |
      | foo      | POLYGON ((1 1, -1 2, 1 3, 1 1)) | OPENSEARCH |
    Then I should see a valid collection atom response
    And I should see 1 result
    And result 1 should have a the following echo characteristics,
      | shortName              | versionId | datasetId                        | dataCenter |
      | SpatialTestingDataset1 | 1         | Spatial Testing dataset number 1 | OS_PROV_1  |
    And result 1 should have a description of "Spatial test 1 - OPENSEARCH"
    And result 1 should not have a link to a granule search
    And result 1 should not have a link to a granule open search descriptor document
    And I should see a query element with the following characteristics,
      | geo:geometry                    |
      | POLYGON ((1 1, -1 2, 1 3, 1 1)) |

  Scenario: Search for collection using WKT polygon (no hit)
    Given I have executed a collection search with the following parameters:
      | clientId | geometry                                      | keyword    |
      | foo      | POLYGON ((30 10, 10 20, 20 40, 40 40, 30 10)) | OPENSEARCH |
    Then I should see a valid collection atom response
    And I should see 0 results
    And I should see a query element with the following characteristics,
      | geo:geometry                                  |
      | POLYGON ((30 10, 10 20, 20 40, 40 40, 30 10)) |

