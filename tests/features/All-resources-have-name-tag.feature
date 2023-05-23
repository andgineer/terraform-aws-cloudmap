Feature: All created resources have Name tag

  Scenario Outline: Ensure that My-tag tags are defined in all created resources
    Given I have resource that supports tags_all defined
    When it has tags_all
    Then it must contain tags_all
    Then it must contain "<tags>"
    And its value must match the "<value>" regex

    Examples:
      | tags   | value  |
      | My-tag | my-tag |
