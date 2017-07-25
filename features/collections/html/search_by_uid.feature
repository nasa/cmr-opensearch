@datasets_search_by_uid_html
Feature: Retrieve collections in html format
  In order to obtain collection products
  as an open search user
  I should be able to search for collections using a unique id with a human-centric mechanism

  Scenario: Search for collection using uid
    Given I have executed a html collection search with the following parameters:
      | input   | value                         |
      | keyword | First dataset for open search |
    Then I should see 1 collection result
    And I execute a html collection search using the unique id associated with result number 1
    Then I should see 1 collection result
    And collection result 1 should have a the following echo characteristics,
      | characteristic | value        |
      | short_name     | FirstDataset |

