@granules_search_atom
Feature: Retrieve granules in atom format
  In order to obtain granule products
  as an open search user
  I should be able to search for granules using a machine-readable format

  Scenario: Search for granule using spatial bounding box
    Given I have executed a granule search with the following parameters:
      | clientId | boundingBox |
      | foo      | -5,-5,5,5   |
    Then I should see a valid granule atom response
    And I should see a subtitle of "Search parameters: boundingBox => -5,-5,5,5"
    And I should see 1 result
    And result 1 should have a the following echo characteristics,
      | producerGranuleId      |
      | SpatialTestingGranule2 |

  Scenario: Search for granule using spatial bounding box (no hit)
    Given I have executed a granule search with the following parameters:
      | clientId | boundingBox |
      | foo      | 30,30,40,40 |
    Then I should see a valid granule atom response
    And I should see 0 results
    And I should see a subtitle of "Your search yielded zero matches"

  Scenario: Search for granule using temporal constraints (constraint engulfs extent)
    Given I have executed a granule search with the following parameters:
      | clientId | startTime            | endTime              | dataCenter |
      | foo      | 2001-01-01T22:00:00Z | 2001-01-01T23:00:00Z | OS_PROV_1  |
    Then I should see a valid granule atom response
    And I should see an open search query node in the results corresponding to:
      | time:start           | time:end             |
      | 2001-01-01T22:00:00Z | 2001-01-01T23:00:00Z |
    Then I should see 1 result
    And result 1 should have a the following echo characteristics,
      | producerGranuleId       |
      | TemporalTestingGranule1 |

  Scenario: Search for granule using temporal constraints (constraint not in extent)
    Given I have executed a granule search with the following parameters:
      | clientId | startTime            | endTime              | dataCenter |
      | foo      | 1999-01-01T22:00:00Z | 1999-02-01T23:00:00Z | OS_PROV_1  |
    Then I should see a valid granule atom response
    And I should see 0 results
    And I should see a subtitle of "Your search yielded zero matches"

  Scenario: Search for granule using temporal constraints (constraint overlaps extent)
    Given I have executed a granule search with the following parameters:
      | clientId | startTime            | endTime              | dataCenter |
      | foo      | 2001-01-01T22:00:00Z | 2001-05-01T23:00:00Z | OS_PROV_1  |
    Then I should see a valid granule atom response
    Then I should see 1 result
    And result 1 should have a the following echo characteristics,
      | producerGranuleId       |
      | TemporalTestingGranule1 |

  Scenario: Search for granule using temporal constraints (constraint overlaps extent all)
    Given I have executed a granule search with the following parameters:
      | clientId | startTime            | endTime              | dataCenter |
      | foo      | 2000-01-01T22:00:00Z | 2012-05-01T23:00:00Z | OS_PROV_1  |
    Then I should see a valid granule atom response
    Then I should see 2 results

  Scenario: Search for granule using short name
    Given I have executed a granule search with the following parameters:
      | clientId | shortName               |
      | foo      | ShortNameSearchTesting1 |
    Then I should see a valid granule atom response
    Then I should see 1 result
    And result 1 should have a the following echo characteristics,
      | producerGranuleId        |
      | ShortNameTestingGranule1 |

  Scenario: Search for granule using short name (no hit)
    Given I have executed a granule search with the following parameters:
      | clientId | shortName |
      | foo      | bogus     |
    Then I should see a valid granule atom response
    And I should see 0 results
    And I should see a subtitle of "Your search yielded zero matches"

  Scenario: Search for granule using version id
    Given I have executed a granule search with the following parameters:
      | clientId | versionId |
      | foo      | 99        |
    Then I should see a valid granule atom response
    Then I should see 1 result
    And result 1 should have a the following echo characteristics,
      | producerGranuleId        |
      | VersionIdTestingGranule1 |

  Scenario: Search for granule using version id (no hit)
    Given I have executed a granule search with the following parameters:
      | clientId | versionId |
      | foo      | 101       |
    Then I should see a valid granule atom response
    And I should see 0 results
    And I should see a subtitle of "Your search yielded zero matches"

  Scenario: Search for granule using paging
    Given I have executed a granule search with the following parameters:
      | clientId | numberOfResults | cursor | shortName                   |
      | foo      | 2               | 1      | PagingGranuleSearchTesting1 |
    Then I should see a valid granule atom response
    And I should see 2 results
    And I should see a total number of results value of 3
    And I should see a startIndex value of 1
    And I should see a results per page value of 2
    And I have executed a granule search with the following parameters:
      | clientId | numberOfResults | cursor | shortName                   |
      | foo      | 2               | 2      | PagingGranuleSearchTesting1 |
    Then I should see a valid granule atom response
    And I should see 1 result
    And I should see a total number of results value of 3
    And I should see a startIndex value of 3
    And I should see a results per page value of 2

  Scenario: Search for granule renders access urls correctly (no parents)
    Given I have executed a granule search with the following parameters:
      | clientId | shortName          |
      | foo      | UrlGranuleTesting1 |
    Then I should see a valid granule atom response
    And I should see 1 result
    And result 1 should have a browse link with href "http://localhost:8085/800x1000.jpg"
    And result 1 should have a browse link with href "http://localhost:8085/400x600.jpg"
    And result 1 should have a browse link with href "ftp://e4ftl01.cr.usgs.gov/WORKING/BRWS/Browse.001/2006.09.29/BROWSE.MOD13A3.A2000032.h18v03.005.2006271172912.1.jpg"
    And result 1 should have a browse link with href "https://localhost:8086/800x1000.jpg"
    And result 1 should have a browse link with href "http://localhost:8085/_BR_Browse.001_27109907_1.BINARY"
    And result 1 should have a metadata link with href "www.example.com/resource_three.xml"
    And result 1 should have a link to the full granule metadata

  Scenario: Search for granule access urls correctly with parent collection urls to metadata but not browse
    Given I have executed a granule search with the following parameters:
      | clientId | shortName          |
      | foo      | UrlGranuleTesting2 |
    Then I should see a valid granule atom response
    And I should see 1 result
    And result 1 should have a browse link with href "http://localhost:8085/800x1000.jpg"
    And result 1 should have a browse link with href "http://localhost:8085/400x600.jpg"
    And result 1 should have a browse link with href "ftp://e4ftl01.cr.usgs.gov/WORKING/BRWS/Browse.001/2006.09.29/BROWSE.MOD13A3.A2000032.h18v03.005.2006271172912.1.jpg"
    And result 1 should have a browse link with href "https://localhost:8086/800x1000.jpg"
    And result 1 should have a browse link with href "http://localhost:8085/_BR_Browse.001_27109907_1.BINARY"
    And result 1 should not have a browse link with href "ftp://airbornescience.nsstc.nasa.gov/camex4/MAS/browse/"

    And result 1 should not have a metadata link with href "http://daac.ornl.gov//BIGFOOT_VAL/guides/bf_landcover_surf_guide.html"
    And result 1 should not have a data link with href "http://nsidc.org/data/NSIDC-0272.html"

    And result 1 should have a metadata link with href "ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005"
    And result 1 should have a metadata link with href "http://www-airs.jpl.nasa.gov/"
    And result 1 should have a link to the full granule metadata

  Scenario: Search for dataset getting zero results
    Given I have executed a granule search with the following parameters:
      | clientId | shortName     |
      | foo      | noresultsever |
    Then I should see a valid granule atom response
    And I should see 0 results
    And I should not see a startPage element
    And I should not see an itemsPerPage element


