@datasets_search_traversal_html
Feature: Retrieve collections in html format and be able to navigate to and from granule results
  In order to obtain granule products
  as an open search user
  I should be able to search for collections (using a human-centric mechanism) and discover granules from those results

  Scenario: Search for collection using keyword and then granules
    Given I have executed a html collection search with the following parameters:
      | input   | value                         |
      | keyword | First dataset for open search |
    Then I should see 1 collection result
    And collection result 1 should have a description of "This is a description"
    When I search for granules in result 1
    Then I should see the granule search form
    When I click on the link "Collection search"
    Then I should see the following inputs:
      | input   | value                         |
      | keyword | First dataset for open search |
    And I should see the collection search form
    And I should see the following inputs:
      | input   | value                         |
      | keyword | First dataset for open search |

  Scenario: Search for collection using keyword and no granules
    Given I have executed a html collection search with the following parameters:
        | input   | value       |
        | keyword | no_granules |
    Then I should see 1 collection result
    Then I should see "This collection does not contain any granules"
    And I should not see a granule search link within collection 1


  Scenario: Search for collection using bounding box and then granules
    Given I have executed a html collection search with the following parameters:
      | input        | value        |
      | spatial_type | Bounding box |
      | boundingBox  | -5,-5,5,5    |
      | keyword      | OPENSEARCH   |
    Then I should see 1 collection result
    When I search for granules in result 1
    Then I should see the granule search form
    And I should see the following inputs:
      | input        | value     |
      | spatial_type | bbox      |
      | boundingBox  | -5,-5,5,5 |
    When I click on the link "Collection search"
    Then I should see the following inputs:
      | input        | value      |
      | spatial_type | bbox       |
      | boundingBox  | -5,-5,5,5  |
      | keyword      | OPENSEARCH |
    And I should see the collection search form
    Then I should see the following inputs:
      | input        | value      |
      | spatial_type | bbox       |
      | boundingBox  | -5,-5,5,5  |
      | keyword      | OPENSEARCH |

  Scenario: Search for collection using keyword and then granules into second page
    Given I have executed a html collection search with the following parameters:
      | input           | value                         |
      | keyword         | First dataset for open search |
      | cursor          | 1                             |
      | numberOfResults | 3                             |
    Then I should see 1 collection result
    When I search for granules in result 1
    Then I should see the granule search form
    Then I should see the following inputs:
      | input           | value |
      | cursor          | 1     |
      | numberOfResults | 10    |
    And I have executed a html granule search with the following parameters:
      | input           | value |
      | cursor          | 1     |
      | numberOfResults | 1    |
      | shortName       | SampleShortName |
    Then I should see the following inputs:
          | input           | value |
          | cursor          | 1     |
          | numberOfResults | 1     |
    And I click on the link "Collection search"
    Then I should see the following inputs:
      | input           | value |
      | cursor          | 1     |
      | numberOfResults | 3     |

  Scenario: Search for collection using keyword and then granules navigation
    Given I have executed a html collection search with the following parameters:
      | input   | value              |
      | keyword | Granule navigation |
    Then I should see 1 collection result
    Then I should not see "This collection does not contain any granules"
    And I search for granules in result 1
    And I fill in "1" for "numberOfResults"
    And I click on "Search"
    Then I should see 1 granule result