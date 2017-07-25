@datasets_search_by_granules_only_html
Feature: Retrieve collections in html format
  In order to obtain collection products
  as an open search user
  I should be able to search for collections using a unique id with a human-centric mechanism

  Scenario: Search for collections with granules

    Given I have executed a html collection search with the following parameters:
      | input       | value |
      | hasGranules | Yes   |
    Then I should see 2 collection results
    And I should see the following inputs:
      | input       | value |
      | hasGranules | true  |

  Scenario: Search for collections without granules
    Given I have executed a html collection search with the following parameters:
      | input       | value |
      | hasGranules | No    |
    And I should see 1 collection result
    And I should see the following inputs:
      | input       | value |
      | hasGranules | false |

  Scenario: Search for collections without either
    Given I am on the open search home page
    And I search for collections
    Then I should see the collection search form
    And I should see 3 collection results
    And I should see the following inputs:
      | input       | value |
      | hasGranules |       |

