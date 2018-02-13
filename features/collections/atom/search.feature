@datasets_search_atom
Feature: Retrieve datasets in atom format
  In order to obtain collection products
  as an open search user
  I should be able to search for collections using a machine-readable format

  Scenario: Search for collection using keyword
    Given I have executed a collection search with the following parameters:
      | clientId | keyword                       |
      | foo      | First dataset for open search |
    Then I should see a valid collection atom response
    And I should see an open search query node in the results corresponding to:
      | os:searchTerms                |
      | First dataset for open search |
    Then I should see 1 result
    And result 1 should have a the following echo characteristics,
      | shortName    | versionId | datasetId                     | dataCenter |
      | FirstDataset | 1         | First dataset for open search | OS_PROV_1  |
    And result 1 should have a description of "This is a description"
    And result 1 should have a link to a granule search
    And result 1 should have a link to a granule open search descriptor document

  Scenario: Search for collection using spatial bounding box
    Given I have executed a collection search with the following parameters:
      | clientId | boundingBox | keyword    |
      | foo      | -5,-5,5,5   | OPENSEARCH |
    Then I should see a valid collection atom response
    And I should see an open search query node in the results corresponding to:
    | os:searchTerms | geo:box   |
    | OPENSEARCH     | -5,-5,5,5 |
    And I should see a subtitle of "Search parameters: keyword => OPENSEARCH boundingBox => -5,-5,5,5"
    And I should see 1 result
    And result 1 should have a the following echo characteristics,
      | shortName              | versionId | datasetId                        | dataCenter |
      | SpatialTestingDataset1 | 1         | Spatial Testing dataset number 1 | OS_PROV_1  |
    And result 1 should have a description of "Spatial test 1 - OPENSEARCH"
    And result 1 should not have a link to a granule search
    And result 1 should not have a link to a granule open search descriptor document

  Scenario: Search for collection using spatial bounding box (no hit)
    Given I have executed a collection search with the following parameters:
      | clientId | boundingBox | keyword    |
      | foo      | 30,30,40,40 | OPENSEARCH |
    Then I should see a valid collection atom response
    And I should see 0 results
    And I should see a subtitle of "Your search yielded zero matches"

  Scenario: Search for collection using temporal constraints (constraint engulfs extent)
    Given I have executed a collection search with the following parameters:
      | clientId | startTime            | endTime              | keyword    |
      | foo      | 2001-01-01T22:00:00Z | 2001-01-01T23:00:00Z | OPENSEARCH |
    And I should see an open search query node in the results corresponding to:
          | time:start           | time:end             |
          | 2001-01-01T22:00:00Z | 2001-01-01T23:00:00Z |
    Then I should see a valid collection atom response
    Then I should see 1 result
    And result 1 should have a the following echo characteristics,
      | shortName               | versionId | datasetId                         | dataCenter |
      | TemporalTestingDataset1 | 1         | Temporal Testing dataset number 1 | OS_PROV_1  |
    And result 1 should have a description of "Temporal test 1 - OPENSEARCH"
    And result 1 should not have a link to a granule search
    And result 1 should not have a link to a granule open search descriptor document

  Scenario: Search for collection using temporal constraints (constraint not in extent)
    Given I have executed a collection search with the following parameters:
      | clientId | startTime            | endTime              | keyword    |
      | foo      | 1999-01-01T22:00:00Z | 1999-02-01T23:00:00Z | OPENSEARCH |
    Then I should see a valid collection atom response
    And I should see 0 results
    And I should see a subtitle of "Your search yielded zero matches"

  Scenario: Search for collection using temporal constraints (constraint overlaps extent)
    Given I have executed a collection search with the following parameters:
      | clientId | startTime            | endTime              | keyword    |
      | foo      | 2001-01-01T22:00:00Z | 2001-05-01T23:00:00.001Z | OPENSEARCH |
    Then I should see a valid collection atom response
    Then I should see 1 result
    And result 1 should have a the following echo characteristics,
      | shortName               | versionId | datasetId                         | dataCenter |
      | TemporalTestingDataset1 | 1         | Temporal Testing dataset number 1 | OS_PROV_1  |
    And result 1 should have a description of "Temporal test 1 - OPENSEARCH"
    And result 1 should not have a link to a granule search
    And result 1 should not have a link to a granule open search descriptor document

  Scenario: Search for collection using temporal constraints (constraint overlaps extent all)
    Given I have executed a collection search with the following parameters:
      | clientId | startTime            | endTime              | keyword    |
      | foo      | 2000-01-01T22:00:00Z | 2012-05-01T23:00:00Z | OPENSEARCH |
    Then I should see a valid collection atom response
    Then I should see 2 results

  Scenario: Search for collection using instrument
    Given I have executed a collection search with the following parameters:
      | clientId | instrument      | keyword    |
      | foo      | good_instrument | OPENSEARCH |
    Then I should see a valid collection atom response
    And I should see 1 result
    And result 1 should have a the following echo characteristics,
      | shortName                 | versionId | datasetId                          | dataCenter |
      | InstrumentTestingDataset1 | 1         | Instrument Testing dataset number 1 | OS_PROV_1  |
    And result 1 should have a description of "Instrument test 1 - OPENSEARCH"
    And result 1 should not have a link to a granule search
    And result 1 should not have a link to a granule open search descriptor document

  Scenario: Search for collection using instrument (no hit)
    Given I have executed a collection search with the following parameters:
      | clientId | instrument     | keyword    |
      | foo      | bad_instrument | OPENSEARCH |
    Then I should see a valid collection atom response
    And I should see 0 results
    And I should see a subtitle of "Your search yielded zero matches"

  Scenario: Search for collection using satellite
    Given I have executed a collection search with the following parameters:
      | clientId | satellite     | keyword    |
      | foo      | good_platform | OPENSEARCH |
    Then I should see a valid collection atom response
    And I should see 1 result
    And result 1 should have a the following echo characteristics,
      | shortName                 | versionId | datasetId                          | dataCenter |
      | InstrumentTestingDataset1 | 1         | Instrument Testing dataset number 1 | OS_PROV_1  |
    And result 1 should have a description of "Instrument test 1 - OPENSEARCH"
    And result 1 should not have a link to a granule search
    And result 1 should not have a link to a granule open search descriptor document

  Scenario: Search for collection using satellite (no hit)
    Given I have executed a collection search with the following parameters:
      | clientId | satellite    | keyword    |
      | foo      | bad_platform | OPENSEARCH |
    Then I should see a valid collection atom response
    And I should see 0 results
    And I should see a subtitle of "Your search yielded zero matches"

  Scenario: Search for collection using paging
    Given I have executed a collection search with the following parameters:
      | clientId | numberOfResults | cursor | keyword           |
      | foo      | 2               | 1      | Paging OPENSEARCH |
    Then I should see a valid collection atom response
    And I should see 2 results
    And I should see a total number of results value of 3
    And I should see a startIndex value of 1
    And I should see a results per page value of 2
    And I have executed a collection search with the following parameters:
      | clientId | numberOfResults | cursor | keyword           |
      | foo      | 2               | 2      | Paging OPENSEARCH |
    Then I should see a valid collection atom response
    And I should see 1 result
    And I should see a total number of results value of 3
    And I should see a startIndex value of 3
    And I should see a results per page value of 2

  Scenario: Search for collection results in the correct rendering of data access URLS.
    Given I have executed a collection search with the following parameters:
      | clientId | numberOfResults | cursor | keyword        |
      | foo      | 2               | 1      | Url OPENSEARCH |
    Then I should see a valid collection atom response
    And I should see 1 result
    And result 1 should not have a link to a granule search
    And result 1 should not have a link to a granule open search descriptor document
    And result 1 should have a browse link with href "ftp://airbornescience.nsstc.nasa.gov/camex4/MAS/browse/"
    And result 1 should have a documentation link with href "http://nsidc.org/data/NSIDC-0272.html"
    And result 1 should have a metadata link with href "ftp://airsl1.gesdisc.eosdis.nasa.gov/ftp/data/s4pa/Aqua_AIRS_Level1/AIRVBRAD.005"
    And result 1 should have a link to the full collection metadata

  Scenario: Search for collection getting zero results
    Given I have executed a collection search with the following parameters:
      | clientId | keyword       |
      | foo      | noresultsever |
    Then I should see a valid collection atom response
    And I should see 0 results
    And I should not see a startPage element
    And I should not see an itemsPerPage element
