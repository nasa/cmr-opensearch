@datasets_search_html
Feature: Retrieve collections in html format
  In order to obtain collection products
  as an open search user
  I should be able to search for collections using a human-centric mechanism

  Scenario: Search for collections from home page
    Given I am on the open search home page
    And I search for collections
    Then I should see the collection search form
    And I should see the collection results
    And I should see a link to the CMR OpenSearch release documentation

  Scenario: Search for collections with no constraints
    Given I am on the open search collection search page
    And I click on "Search"
    Then I should see 10 collection results
    And I should see the hidden input "clientId" with a value of "our_html_ui"

  Scenario: Search for collection using keyword
    Given I have executed a html collection search with the following parameters:
      | input   | value                         |
      | keyword | First dataset for open search |
    Then I should see 1 collection result
    And collection result 1 should have a the following echo characteristics,
      | characteristic | value        |
      | short_name     | FirstDataset |
      | version_id     | 1            |
      | data_center    | OS_PROV_1    |
    And collection result 1 should have a description of "This is a description"

  Scenario: Search for collection using spatial bounding box
    Given I have executed a html collection search with the following parameters:
      | input        | value        |
      | spatial_type | Bounding box |
      | boundingBox  | -5,-5,5,5    |
      | keyword      | OPENSEARCH   |
    Then I should see 1 collection result
    And collection result 1 should have a the following echo characteristics,
      | characteristic | value                  |
      | short_name     | SpatialTestingDataset1 |
      | version_id     | 1                      |
      | data_center    | OS_PROV_1              |

  Scenario: Search for collection using spatial bounding box (no hit)
    Given I have executed a html collection search with the following parameters:
      | input        | value        |
      | spatial_type | Bounding box |
      | boundingBox  | 30,30,40,40  |
      | keyword      | OPENSEARCH   |
    And I should see 0 collection results

  Scenario: Search for collection using spatial point
    Given I have executed a html collection search with the following parameters:
      | input        | value         |
      | spatial_type | Geometry      |
      | geometry     | POINT (-5 -5) |
      | keyword      | OPENSEARCH    |
    Then I should see 1 collection result
    And collection result 1 should have a the following echo characteristics,
      | characteristic | value                  |
      | short_name     | SpatialTestingDataset1 |
      | version_id     | 1                      |
      | data_center    | OS_PROV_1              |

  Scenario: Search for collection using spatial point (no hit)
    Given I have executed a html collection search with the following parameters:
      | input        | value         |
      | spatial_type | Geometry      |
      | geometry     | POINT (30 30) |
      | keyword      | OPENSEARCH    |
    And I should see 0 collection results

  Scenario: Search for collection using spatial line
    Given I have executed a html collection search with the following parameters:
      | input        | value                   |
      | spatial_type | Geometry                |
      | geometry     | LINESTRING (-5 -5, 4 4) |
      | keyword      | OPENSEARCH              |
    Then I should see 1 collection result
    And collection result 1 should have a the following echo characteristics,
      | characteristic | value                  |
      | short_name     | SpatialTestingDataset1 |
      | version_id     | 1                      |
      | data_center    | OS_PROV_1              |

  Scenario: Search for collection using spatial line (no hit)
    Given I have executed a html collection search with the following parameters:
      | input        | value                     |
      | spatial_type | Geometry                  |
      | geometry     | LINESTRING (30 30, 35 35) |
      | keyword      | OPENSEARCH                |
    And I should see 0 collection results

  Scenario: Search for collection using spatial polygon
    Given I have executed a html collection search with the following parameters:
      | input        | value                           |
      | spatial_type | Geometry                        |
      | geometry     | POLYGON ((1 1, -1 2, 1 3, 1 1)) |
      | keyword      | OPENSEARCH                      |
    Then I should see 1 collection result
    And I should see a spatial extent of "-10.0 -10.0 10.0 10.0"
    And collection result 1 should have a the following echo characteristics,
      | characteristic | value                  |
      | short_name     | SpatialTestingDataset1 |
      | version_id     | 1                      |
      | data_center    | OS_PROV_1              |

  Scenario: Search for collection using spatial polygon (no hit)
    Given I have executed a html collection search with the following parameters:
      | input        | value                                         |
      | spatial_type | Geometry                                      |
      | geometry     | POLYGON ((30 10, 10 20, 20 40, 40 40, 30 10)) |
      | keyword      | OPENSEARCH                                    |
    Then I should see 0 collection results

  Scenario: Search for collection using temporal constraints (constraint engulfs extent)
    Given I have executed a html collection search with the following parameters:
      | input     | value                |
      | startTime | 2001-01-01T22:00:00Z |
      | endTime   | 2001-01-01T23:00:00Z |
      | keyword   | OPENSEARCH           |
    Then I should see 1 collection result
    And collection result 1 should have a the following echo characteristics,
      | characteristic | value                   |
      | short_name     | TemporalTestingDataset1 |
      | version_id     | 1                       |
      | data_center    | OS_PROV_1               |

  Scenario: Search for collection using temporal constraints (constraint not in extent)
    Given I have executed a html collection search with the following parameters:
      | input     | value                |
      | startTime | 1999-01-01T22:00:00Z |
      | endTime   | 1999-02-01T23:00:00.001Z |
      | keyword   | OPENSEARCH           |
    Then I should see 0 collection results

  Scenario: Search for collection using temporal constraints (constraint overlaps extent)
    Given I have executed a html collection search with the following parameters:
      | input     | value                |
      | startTime | 2001-01-01T22:00:00Z |
      | endTime   | 2001-05-01T23:00:00Z |
      | keyword   | OPENSEARCH           |
    Then I should see 1 collection result
    And I should see a temporal start of "2001-01-01T22:00:00Z"
    And collection result 1 should have a the following echo characteristics,
      | characteristic | value                   |
      | short_name     | TemporalTestingDataset1 |
      | version_id     | 1                       |
      | data_center    | OS_PROV_1               |

  Scenario: Search for collection using temporal constraints (constraint overlaps extent) with range
      Given I have executed a html collection search with the following parameters:
        | input     | value                |
        | startTime | 2002-01-01T22:00:00Z |
        | endTime   | 2003-05-01T23:00:00Z |
        | keyword   | OPENSEARCH           |
      Then I should see 1 collection result
      And I should see a temporal start of "2002-01-01T00:00:00Z"
      And I should see a temporal end of "2003-12-01T00:00:00Z"
      And collection result 1 should have a the following echo characteristics,
        | characteristic | value                   |
        | short_name     | TemporalTestingDataset2 |
        | version_id     | 1                       |
        | data_center    | OS_PROV_1               |

  Scenario: Search for dataset using temporal constraints (constraint overlaps extent all)
    Given I have executed a html collection search with the following parameters:
      | input     | value                |
      | startTime | 2000-01-01T22:00:00Z |
      | endTime   | 2012-05-01T23:00:00Z |
      | keyword   | OPENSEARCH           |
    Then I should see 2 collection results

  Scenario: Search for collection using instrument
    Given I have executed a html collection search with the following parameters:
      | input      | value           |
      | instrument | good_instrument |
      | keyword    | OPENSEARCH      |
    Then I should see 1 collection result
    And collection result 1 should have a the following echo characteristics,
      | characteristic | value                     |
      | short_name     | InstrumentTestingDataset1 |
      | version_id     | 1                         |
      | data_center    | OS_PROV_1                 |

  Scenario: Search for collection using instrument (no hit)
    Given I have executed a html collection search with the following parameters:
      | input      | value          |
      | instrument | bad_instrument |
      | keyword    | OPENSEARCH     |
    Then I should see 0 collection results

  Scenario: Search for collection using satellite
    Given I have executed a html collection search with the following parameters:
      | input     | value         |
      | satellite | good_platform |
      | keyword   | OPENSEARCH    |
    Then I should see 1 collection result
    And collection result 1 should have a the following echo characteristics,
      | characteristic | value                     |
      | short_name     | InstrumentTestingDataset1 |
      | version_id     | 1                         |
      | data_center    | OS_PROV_1                 |

  Scenario: Search for collection using satellite (no hit)
    Given I have executed a collection search with the following parameters:
      | input     | value        |
      | satellite | bad_platform |
      | keyword   | OPENSEARCH   |
    Then I should see 0 collection results

  Scenario: Search for collection using paging
    Given I have executed a html collection search with the following parameters:
      | input           | value             |
      | numberOfResults | 2                 |
      | cursor          | 1                 |
      | keyword         | Paging OPENSEARCH |
    Then I should see 2 collection results
    And I should see "1 to 2 of 3"
    Given I have executed a html collection search with the following parameters:
      | input           | value             |
      | numberOfResults | 2                 |
      | cursor          | 2                 |
      | keyword         | Paging OPENSEARCH |
    Then I should see 1 collection result
    And I should see "3 to 3 of 3"

  Scenario: Search for collection with urls
    Given I have executed a html collection search with the following parameters:
      | input           | value          |
      | numberOfResults | 2              |
      | cursor          | 1              |
      | keyword         | Url OPENSEARCH |
    Then I should see 1 collection result
    And dataset result 1 should have a browse link with href "ftp://airbornescience.nsstc.nasa.gov/camex4/MAS/browse/"
    And dataset result 1 should have a data link with href "http://nsidc.org/data/NSIDC-0272.html"
    And dataset result 1 should have a metadata link with href "ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005"