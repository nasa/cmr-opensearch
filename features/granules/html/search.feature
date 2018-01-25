@granules_search_html
Feature: Retrieve granules in html format
  In order to obtain granule products
  as an open search user
  I should be able to search for granules using a human-centric mechanism

  Scenario: Search for granules from home page
    Given I am on the open search home page
    And I search for granules
    Then I should see the granule search form
    #And I should see the granule results
    And I should see a link to the CMR OpenSearch release documentation

  Scenario: Search for granules with no constraints
    Given I am on the open search granule search page
    And I click on "Search"
    Then I should see 0 granule results
    And I should see 3 error messages
    And I should see "Short name : A granule search requires the Collection ConceptID or the Collection ShortName or the Granule Unique Identifier"
    And I should see "Collection concept ID : A granule search requires the Collection ConceptID or the Collection ShortName or the Granule Unique Identifier"
    And I should see "Unique ID : A granule search requires the Collection ConceptID or the Collection ShortName or the Granule Unique Identifier"
    And I should see the hidden input "clientId" with a value of "our_html_ui"

  Scenario: Search for granule using spatial bounding box
    Given I have executed a html granule search with the following parameters:
      | input        | value        |
      | spatial_type | Bounding box |
      | boundingBox  | -5,-5,5,5    |
      | shortName    | SampleShortName |
    Then I should see 1 granule result
    And granule result 1 should have a the following echo characteristics,
      | characteristic | value                  |
      | granule_ur     | SpatialTestingGranule2 |

  Scenario: Search for granule using spatial bounding box (no hit)
    Given I have executed a html granule search with the following parameters:
      | input        | value        |
      | spatial_type | Bounding box |
      | boundingBox  | 30,30,40,40  |
      | shortName    | SampleShortName |
    And I should see 0 granule results

  Scenario: Search for granule using spatial point
    Given I have executed a html granule search with the following parameters:
      | input        | value         |
      | spatial_type | Geometry      |
      | geometry     | POINT (-5 -5) |
      | shortName    | SampleShortName |
    Then I should see 1 granule result
    And granule result 1 should have a the following echo characteristics,
      | characteristic | value                  |
      | granule_ur     | SpatialTestingGranule2 |

  Scenario: Search for granule using spatial point (no hit)
    Given I have executed a html granule search with the following parameters:
      | input        | value         |
      | spatial_type | Geometry      |
      | geometry     | POINT (30 30) |
      | shortName    | SampleShortName |
    And I should see 0 granule results

  Scenario: Search for granule using spatial line
    Given I have executed a html granule search with the following parameters:
      | input        | value                   |
      | spatial_type | Geometry                |
      | geometry     | LINESTRING (-5 -5, 4 4) |
      | shortName    | SampleShortName |
    Then I should see 1 granule result
    And granule result 1 should have a the following echo characteristics,
      | characteristic | value                  |
      | granule_ur     | SpatialTestingGranule2 |

  Scenario: Search for granule using spatial line (no hit)
    Given I have executed a html granule search with the following parameters:
      | input        | value                     |
      | spatial_type | Geometry                  |
      | geometry     | LINESTRING (30 30, 35 35) |
      | shortName    | SampleShortName |
    And I should see 0 granule results

  Scenario: Search for granule using spatial polygon
    Given I have executed a html granule search with the following parameters:
      | input        | value                           |
      | spatial_type | Geometry                        |
      | geometry     | POLYGON ((1 1, -1 2, 1 3, 1 1)) |
      | shortName    | SampleShortName |
    Then I should see 1 granule result
    And granule result 1 should have a the following echo characteristics,
      | characteristic | value                  |
      | granule_ur     | SpatialTestingGranule2 |

  Scenario: Search for granule using spatial polygon (no hit)
    Given I have executed a html granule search with the following parameters:
      | input        | value                                         |
      | spatial_type | Geometry                                      |
      | geometry     | POLYGON ((30 10, 10 20, 20 40, 40 40, 30 10)) |
      | shortName    | SampleShortName |
    Then I should see 0 granule results

  Scenario: Search for granule using temporal constraints (constraint engulfs extent)
    Given I have executed a html granule search with the following parameters:
      | input      | value                |
      | startTime  | 2001-01-01T22:00:00Z |
      | endTime    | 2001-01-01T23:00:00Z |
      | dataCenter | OS_PROV_1            |
      | shortName  | SampleShortName |
    Then I should see 1 granule result
    And granule result 1 should have a the following echo characteristics,
      | characteristic | value                   |
      | granule_ur     | TemporalTestingGranule1 |

  Scenario: Search for granule using temporal constraints (constraint not in extent)
    Given I have executed a html granule search with the following parameters:
      | input      | value                |
      | startTime  | 1999-01-01T22:00:00Z |
      | endTime    | 1999-02-01T23:00:00Z |
      | dataCenter | OS_PROV_1            |
      | shortName  | SampleShortName      |
    Then I should see 0 granule results

  Scenario: Search for granule using temporal constraints (constraint overlaps extent)
    Given I have executed a html granule search with the following parameters:
      | input      | value                |
      | startTime  | 2001-01-01T22:00:00Z |
      | endTime    | 2001-05-01T23:00:00Z |
      | dataCenter | OS_PROV_1            |
      | shortName  | SampleShortName      |
    Then I should see 1 granule result
    And granule result 1 should have a the following echo characteristics,
      | characteristic | value                   |
      | granule_ur     | TemporalTestingGranule1 |

  Scenario: Search for granule using temporal constraints (constraint overlaps extent all)
    Given I have executed a html granule search with the following parameters:
      | input      | value                |
      | startTime  | 2000-01-01T22:00:00Z |
      | endTime    | 2012-05-01T23:00:00Z |
      | dataCenter | OS_PROV_1            |
      | shortName  | SampleShortName      |
    Then I should see 2 granule results

  Scenario: Search for granule using short name
    Given I have executed a html granule search with the following parameters:
      | input     | value                   |
      | shortName | ShortNameSearchTesting1 |
    Then I should see 1 granule result
    And granule result 1 should have a the following echo characteristics,
      | characteristic | value                    |
      | granule_ur     | ShortNameTestingGranule1 |

  Scenario: Search for granule using short name (no hit)
    Given I have executed a html granule search with the following parameters:
      | input     | value |
      | shortName | bogus |
    Then I should see 0 granule results

  Scenario: Search for granule using version id
    Given I have executed a html granule search with the following parameters:
      | input     | value                |
      | shortName | SampleShortName      |
      | versionId | 99                   |
    Then I should see 1 granule result
    And granule result 1 should have a the following echo characteristics,
      | characteristic | value                    |
      | granule_ur     | VersionIdTestingGranule1 |

  Scenario: Search for granule using version id (no hit)
    Given I have executed a html granule search with the following parameters:
      | input     | value |
      | versionId | 101   |
      | shortName  | SampleShortName      |
    Then I should see 0 granule results

  Scenario: Search for granule using paging
    Given I have executed a html granule search with the following parameters:
      | input           | value                       |
      | numberOfResults | 2                           |
      | cursor          | 1                           |
      | shortName       | PagingGranuleSearchTesting1 |
    Then I should see 2 granule results
    And I should see "1 to 2 of 3"
    Given I have executed a html granule search with the following parameters:
      | input           | value                       |
      | numberOfResults | 2                           |
      | cursor          | 2                           |
      | shortName       | PagingGranuleSearchTesting1 |
    Then I should see 1 granule result
    And I should see "3 to 3 of 3"

  Scenario: Search for granule with urls (no parents)
    Given I have executed a html granule search with the following parameters:
      | input     | value              |
      | shortName | UrlGranuleTesting1 |
    Then I should see 1 granule result
    And granule result 1 should have a browse link with href "http://localhost:8085/800x1000.jpg"
    And granule result 1 should have a browse link with href "http://localhost:8085/400x600.jpg"
    And granule result 1 should have a browse link with href "ftp://e4ftl01.cr.usgs.gov/WORKING/BRWS/Browse.001/2006.09.29/BROWSE.MOD13A3.A2000032.h18v03.005.2006271172912.1.jpg"
    And granule result 1 should have a browse link with href "https://localhost:8086/800x1000.jpg"
    And granule result 1 should have a browse link with href "http://localhost:8085/_BR_Browse.001_27109907_1.BINARY"
    And granule result 1 should have a metadata link with href "www.example.com/resource_three.xml"

  Scenario: Search for granule with urls (with parents)
    Given I have executed a html granule search with the following parameters:
      | input     | value              |
      | shortName | UrlGranuleTesting2 |
    Then I should see 1 granule result
    And granule result 1 should have a browse link with href "http://localhost:8085/800x1000.jpg"
    And granule result 1 should have a browse link with href "http://localhost:8085/400x600.jpg"
    And granule result 1 should have a browse link with href "ftp://e4ftl01.cr.usgs.gov/WORKING/BRWS/Browse.001/2006.09.29/BROWSE.MOD13A3.A2000032.h18v03.005.2006271172912.1.jpg"
    And granule result 1 should have a browse link with href "https://localhost:8086/800x1000.jpg"
    And granule result 1 should have a browse link with href "http://localhost:8085/_BR_Browse.001_27109907_1.BINARY"
    And granule result 1 should not have a browse link with href "ftp://airbornescience.nsstc.nasa.gov/camex4/MAS/browse/"

    And granule result 1 should not have a metadata link with href "http://daac.ornl.gov//BIGFOOT_VAL/guides/bf_landcover_surf_guide.html"
    And granule result 1 should not have a data link with href "http://nsidc.org/data/NSIDC-0272.html"

    And granule result 1 should have a metadata link with href "ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005"
    And granule result 1 should have a metadata link with href "http://www-airs.jpl.nasa.gov/"
    And I should not see a granule search link within granule 1
    And I should not see "This collection does not contain any granules" within granule 1

