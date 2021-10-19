Feature: color_item
   Color Items are supported

   Background:
     Given Clean OpenHAB with latest Ruby Libraries
     And items:
       | type  | name  |
       | Color | Color |

   Scenario Outline:  Color items can be updated
     Given code in a rules file:
       """
       Color << <command>
       """
     When I deploy the rules file
     Then "Color" should be in state "<final>" within 5 seconds
     Examples:
       | command                     | final     |
       | HSBType.new(0, 100, 100)    | 0,100,100 |
       | HSBType.from_rgb(255, 0, 0) | 0,100,100 |
