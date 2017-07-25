@datasets_search_by_cwic_only_html
Feature: Retrieve collections in html format
  In order to obtain collection products
  as an open search user
  I should be able to search for collections using a machine-readable format that are resident in CWIC

  Scenario: Search for collections from CWIC

    Given I have executed a html collection search with the following parameters:
      | input  | value |
      | isCwic | Yes   |
    Then I should see 2 collection results
    And I should see the following inputs:
      | input  | value |
      | isCwic | true  |

  Scenario: Search for collections
    Given I am on the open search home page
    And I search for collections
    Then I should see the collection search form
    And I should see 3 collection results
    And I should see the following inputs:
      | input  | value |
      | isCwic |       |

  Scenario: Search for collections and Don't Care
    Given I have executed a html collection search with the following parameters:
          | input  | value       |
          | isCwic | Don't care  |
    Then I should see the collection search form
    And I should see 3 collection results
    And I should see the following inputs:
      | input  | value |
      | isCwic |       |


