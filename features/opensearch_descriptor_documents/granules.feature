@granules_osdd
Feature: Retrieve granule Open Search Descriptor Document (OSDD)
  In order to obtain granule products
  as an open search user
  I should be able to obtain an open search descriptor document for granules

Scenario: Generate granule open search descriptor document with client id only
  Given I am on the open search home page
  And I fill in the "granules" open search descriptor form with a client id of "foo"
  And I click on "Generate" within the "granules" form
  Then I should see a granule open search descriptor document for client id "foo"

Scenario: Generate granule open search descriptor document with client id and dataset id
  Given I am on the open search home page
  And I fill in the "granules" open search descriptor form with a client id of "foo"
  And I fill in the "granules" open search descriptor form with a short name of "MOD02QKM"
  And I click on "Generate" within the "granules" form
  Then I should see a granule open search descriptor document for client id "foo" and short name "MOD02QKM"

Scenario: Generate granule open search descriptor document with client id, short name and version id
  Given I am on the open search home page
  And I fill in the "granules" open search descriptor form with a client id of "foo"
  And I fill in the "granules" open search descriptor form with a short name of "MOD02QKM"
  And I fill in the "granules" open search descriptor form with a version id of "5"
  And I click on "Generate" within the "granules" form
  Then I should see a granule open search descriptor document for client id "foo" short name "MOD02QKM" and version id "5"

Scenario: Generate granule open search descriptor document with client id, short name, version id and data center
  Given I am on the open search home page
  And I fill in the "granules" open search descriptor form with a client id of "foo"
  And I fill in the "granules" open search descriptor form with a short name of "MOD02QKM"
  And I fill in the "granules" open search descriptor form with a version id of "5"
  And I fill in the "granules" open search descriptor form with a data center of "LAADS"
  And I click on "Generate" within the "granules" form
  Then I should see a granule open search descriptor document for client id "foo" short name "MOD02QKM" version id "5" and data center "LAADS"

Scenario: Generate granule open search descriptor document and see attribution and syndication
  Given I am on the open search home page
  And I fill in the "granules" open search descriptor form with a client id of "foo"
  And I click on "Generate" within the "granules" form
  Then I should see a granule open search descriptor document for client id "foo"
  And I should see an attribution of "NASA CMR"
  And I should see a syndication right of "open"
