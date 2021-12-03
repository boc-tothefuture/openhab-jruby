Feature: color_item
   Color Items are supported

   Background:
     Given Clean OpenHAB with latest Ruby Libraries
     And items:
       | type  | name  | state |
       | Color | Color | 0,0,0 |

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
       | '0,100,100'                 | 0,100,100 |
       | '#FF0000'                   | 0,100,100 |

   Scenario Outline:  Color items support hash values
     Given code in a rules file:
       """
       Color << <command>
       """
     When I deploy the rules file
     Then "Color" should be in state "<final>" within 5 seconds
     Examples:
       | command                                                      | final     |
       | {r: 255, g: 0, b: 0}                                         | 0,100,100 |
       | {'r' => 255, 'g' => 0, 'b' => 0}                             | 0,100,100 |
       | {red: 255, green: 0, blue: 0}                                | 0,100,100 |
       | {'red' => 255, 'green' => 0, 'blue' => 0}                    | 0,100,100 |
       | {h: 0, s: 100, b: 100}                                       | 0,100,100 |
       | {'h' =>  0, 's' => 100, 'b' => 100}                          | 0,100,100 |
       | {hue: 0, saturation: 100, brightness: 100}                   | 0,100,100 |
       | {'hue' =>  0, 'saturation' => 100, 'brightness' => 100}      | 0,100,100 |

   Scenario Outline:  Color items can be converted to hashes and arrays
    Given items:
       | type  | name  | state     |
       | Color | Color | 0,100,100 |
    Given code in a rules file:
       """
       logger.info(Color.<command>)
       """
     When I deploy the rules file
     Then It should log "<log_line>" within 5 seconds
     Examples:
       | command       | log_line                                          |
       | to_h          | {:hue=>0 °, :saturation=>100%, :brightness=>100%} |
       | to_h(:hsb)    | {:hue=>0 °, :saturation=>100%, :brightness=>100%} |
       | to_h(:rgb)    | {:red=>255, :green=>0, :blue=>0}                  |
       | to_a          | [0 °, 100%, 100%]                                 |
       | to_a(:hsb)    | [0 °, 100%, 100%]                                 |
       | to_a(:rgb)    | [255, 0, 0]                                       |

