@datasets_search_by_uid_atom
Feature: Retrieve collections in atom format
  In order to obtain collection products
  as an open search user
  I should be able to search for collections using a machine-readable format using a unique id associated with that dataset

  Scenario: Search for collection using unique id
    Given I have executed a collection search with the following parameters:
      | clientId | keyword                       |
      | foo      | First dataset for open search |
    Then I should see a valid collection atom response
    And I execute a collection search using the unique id associated with result number 1
    Then I should see a valid collection atom response
    Then I should see 1 result
    And result 1 should have a the following echo characteristics,
      | shortName    | versionId | datasetId                     | dataCenter |
      | FirstDataset | 1         | First dataset for open search | OS_PROV_1  |
    And result 1 should have a description of "This is a description"
    And result 1 should not have a link to a granule search
    And result 1 should not have a link to a granule open search descriptor document

