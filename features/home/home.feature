Feature: Retrieve home page
  In order to obtain dataset and granule products
  as an open search user
  I should be able to navigate to the open search home page

Scenario: View Home Page
  Given I am on the open search home page
  Then I should see a page title reading "CMR OpenSearch"
  And I should see "CMR provides a search interface based on the OpenSearch concept in general and the ESIP (Earth Science Information Partners) federated search concept in particular."
  And I should see the subtitle "Collections"
  And I should see the subtitle "Granules"
  And I should see "NASA Official: Stephen Berrick"
  And I should see the current version of CMR
  And I should see a link to the CMR OpenSearch release documentation