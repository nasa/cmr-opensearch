@granules_search_by_dataset_id_atom
Feature: Retrieve granules in atom format
  In order to obtain granule products
  as an open search user
  I should be able to specify dataset id as spatial search constraint

  Scenario: Search for granule using dataset id
    Given I have executed a granule search with the following parameters:
      | clientId | datasetId    |
      | foo      | Cool Dataset |
    Then I should see a valid granule atom response
    And I should see 1 result
    And result 1 should have a the following echo characteristics,
      | datasetId       | cool_dataset_id |

  Scenario: Search for granule using invalid dataset id
    Given I have executed a granule search with the following parameters:
      | clientId | datasetId      |
      | foo      | Uncool Dataset |
    Then I should see a valid granule atom response
    And I should see 0 results

