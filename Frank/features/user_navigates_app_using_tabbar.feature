Feature: User navigates app using tab bar
  In order to be able to navigate through an application
  as a User
  I should be able to click the tab bar and be taken to a specific controller.


  Background:
    Given I launch the app

  Scenario: User sees default icons when app starts up
    Then I should see "ICN home ON"
    And I should see "ICN saved"
    And I should see "ICN tab search"
    And I should see "ICN more"
    But I should not see "ICN recent" on the screen
    And I should not see "ICN account" on the screen
    And I should not see "ICN brand" on the screen
    And I should not see "ICN tab info" on the screen
