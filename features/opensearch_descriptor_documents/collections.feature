@datasets_osdd
Feature: Retrieve collection Open Search Descriptor Document (OSDD)
  In order to obtain dataset and granule products
  as an open search user
  I should be able to obtain an open search descriptor document for datasets

Scenario: Generate collection open search descriptor document
  Given I am on the open search home page
  And I fill in the "collections" open search descriptor form with a client id of "foo"
  And I click on "Generate" within the "collections" form
  Then I should see a collection open search descriptor document for client id "foo"

Scenario: Generate collection open search descriptor document using an invalid client id
  Given I am on the open search home page
  And I fill in the "collections" open search descriptor form with a client id of "foo bar"
  And I click on "Generate" within the "collections" form
  Then I should see the error message "Unable to process request : Clientid is invalid, it must be an alpha-numeric string"

Scenario: Generate collection open search descriptor document and use it to do a dataset search
  Given I am on the open search home page
  And I fill in the "collections" open search descriptor form with a client id of "foo"
  And I click on "Generate" within the "collections" form
  And I perform a dataset search using the open search descriptor template
  Then I should see a valid collection atom response

Scenario: Generate collection open search descriptor document and see attribution and syndication
  Given I am on the open search home page
  And I fill in the "collections" open search descriptor form with a client id of "foo"
  And I click on "Generate" within the "collections" form
  Then I should see a collection open search descriptor document for client id "foo"
  And I should see an attribution of "NASA CMR"
  And I should see a syndication right of "open"
