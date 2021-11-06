Feature: comparisons
  Rule language supports comparisons of different types

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And groups:
      | name         | type               | function | params       |
      | Temperatures | Number:Temperature | AVG      |              |
      | Switches     | Switch             | AND      | ON, OFF      |
      | Contacts     | Contact            | OR       | OPEN, CLOSED |
      | Dates        | DateTime           | LATEST   |              |
      | Shutters     | Rollershutter      | AND      | UP, DOWN     |
      | ShuttersPos  | Rollershutter      | MAX      |              |

    And items:
      | type               | name            | label                   | groups                | state                     |
      | Number             | Number5         | Number Five             |                       | 5                         |
      | Number             | Number10        | Number Ten              |                       | 10                        |
      | Number             | Number10A       | Number Ten A            |                       | 10                        |
      | Number             | Number20        | Number Twenty           |                       | 20                        |
      | Number             | NumberNull      | Number NULL             |                       | NULL                      |
      | Number             | NumberNullA     | Number NULL A           |                       | NULL                      |
      | Number:Temperature | Number5C        | Number Five             | Temperatures          | 5°C                       |
      | Number:Temperature | Number10C       | Number Ten              | Temperatures          | 10°C                      |
      | Number:Temperature | Number10C2      | Number Ten              | Temperatures          | 10°C                      |
      | Number:Temperature | Number20C       | Number Twenty           | Temperatures          | 20°C                      |
      | Number:Illuminance | NumberLux       | Number Lux              |                       | 465.3 lx                  |
      | Dimmer             | Dimmer5         | Dimmer Five             |                       | 5                         |
      | Dimmer             | Dimmer10        | Dimmer Ten              |                       | 10                        |
      | Switch             | SwitchOne       | Switch One              | Switches              | ON                        |
      | Switch             | SwitchTwo       | Switch Two              | Switches              | OFF                       |
      | Contact            | ContactOne      | Contact One             | Contacts              | OPEN                      |
      | Contact            | ContactTwo      | Contact Two             | Contacts              | CLOSED                    |
      | DateTime           | DateOne         | Date One                | Dates                 | 2021-01-01T00:00:00+00:00 |
      | DateTime           | DateTwo         | Date Two                | Dates                 | 2021-02-01T12:00:00+00:00 |
      | Rollershutter      | ShutterOne      | Shutter One             | Shutters, ShuttersPos | 0                         |
      | Rollershutter      | ShutterTwo      | Shutter Two             | Shutters, ShuttersPos | 50                        |
      | Color              | Color           | Color                   |                       | 0, 100, 100               |

  Scenario: Comparisons can be done against different types
    Given code in a rules file
      """
      java_import org.openhab.core.library.types.DateTimeType
      java_import org.openhab.core.library.types.DecimalType
      java_import org.openhab.core.library.types.PercentType

      #comparison pairs
      tests = [
        # NumberItem vs NumberItem
        [ Number10                    , 'eql?', Number10                    , true  ]  ,
        [ Number10                    , 'eql?', Number10A                   , false ]  ,
        [ Number10                    , '=='  , Number10A                   , true  ]  ,
        [ Number10                    , '=='  , Number5                     , false ]  ,
        [ NumberNull                  , '=='  , NumberNullA                 , true  ]  ,
        [ Number10                    , '!='  , Number5                     , true  ]  ,
        [ Number10                    , '!='  , Number10A                   , false ]  ,

        [ Number10                    , '<'   , Number20                    , true  ]  ,
        [ Number10                    , '<'   , Number5                     , false ]  ,
        [ Number10                    , '>'   , Number5                     , true  ]  ,
        [ Number10                    , '>'   , Number20                    , false ]  ,

        # NumberItem vs DecimalType
        [ Number10                    , 'eql?', DecimalType.new(10)         , false ]  ,
        [ Number10                    , '=='  , DecimalType.new(10)         , true  ]  ,
        [ Number10                    , '=='  , DecimalType.new(5)          , false ]  ,
        [ Number10                    , '!='  , DecimalType.new(5)          , true  ]  ,
        [ Number10                    , '!='  , DecimalType.new(10)         , false ]  ,

        [ Number10                    , '<'   , DecimalType.new(20)         , true  ]  ,
        [ Number10                    , '<'   , DecimalType.new(5)          , false ]  ,
        [ Number10                    , '>'   , DecimalType.new(5)          , true  ]  ,
        [ Number10                    , '>'   , DecimalType.new(20)         , false ]  ,        

        # NumberItem vs Ruby Numeric
        [ Number10                    , 'eql?', 10                          , false ]  ,
        [ Number10                    , '=='  , 10                          , true  ]  ,
        [ Number10                    , '=='  , 1                           , false ]  ,
        [ Number10                    , '!='  , 1                           , true  ]  ,
        [ Number10                    , '!='  , 10                          , false ]  ,

        [ Number10                    , '<'   , 10.1                        , true  ]  ,
        [ Number10                    , '<'   , 5                           , false ]  ,
        [ Number10                    , '>'   , 5                           , true  ]  ,
        [ Number10                    , '>'   , 10.1                        , false ]  ,

        # Ruby Numeric vs NumberItem
        [ 10                          , 'eql?', Number10                    , false ]  ,
        [ 10                          , '=='  , Number10                    , true  ]  ,
        [ 10                          , '=='  , Number5                     , false ]  ,
        [ 10                          , '!='  , Number5                     , true  ]  ,
        [ 10                          , '!='  , Number10                    , false ]  ,

        [ 10.5                        , '<'   , Number20                    , true  ]  ,
        [ 10                          , '<'   , Number5                     , false ]  ,
        [ 10                          , '>'   , Number5                     , true  ]  ,
        [ 10                          , '>'   , Number10                    , false ]  ,

        # DecimalType vs NumberItem
        [ DecimalType.new(10)         , 'eql?', Number10                    , false ]  ,
        [ DecimalType.new(10)         , '=='  , Number10                    , true  ]  ,
        [ DecimalType.new(10)         , '=='  , Number5                     , false ]  ,
        [ DecimalType.new(10)         , '!='  , Number5                     , true  ]  ,
        [ DecimalType.new(10)         , '!='  , Number10                    , false ]  ,

        [ DecimalType.new(10.5)       , '<'   , Number20                    , true  ]  ,
        [ DecimalType.new(10)         , '<'   , Number5                     , false ]  ,
        [ DecimalType.new(10)         , '>'   , Number5                     , true  ]  ,
        [ DecimalType.new(10)         , '>'   , Number10                    , false ]  ,

        # NumberItem vs DimmerItem
        [ Number10                    , 'eql?', Dimmer10                    , false ]  ,
        [ Number10                    , '=='  , Dimmer10                    , true  ]  ,
        [ Number10                    , '=='  , Dimmer5                     , false ]  ,
        [ Number10                    , '!='  , Dimmer5                     , true  ]  ,
        [ Number10                    , '!='  , Dimmer10                    , false ]  ,

        [ Number5                     , '<'   , Dimmer10                    , true  ]  ,
        [ Number10                    , '<'   , Dimmer5                     , false ]  ,
        [ Number10                    , '>'   , Dimmer5                     , true  ]  ,
        [ Number5                     , '>'   , Dimmer10                    , false ]  ,

        # DimmerItem vs NumberItem
        [ Dimmer10                    , 'eql?', Number10                    , false ]  ,
        [ Dimmer10                    , '=='  , Number10                    , true  ]  ,
        [ Dimmer10                    , '=='  , Number5                     , false ]  ,
        [ Dimmer10                    , '!='  , Number5                     , true  ]  ,
        [ Dimmer10                    , '!='  , Number10                    , false ]  ,

        [ Dimmer10                    , '<'   , Number20                    , true  ]  ,
        [ Dimmer10                    , '<'   , Number5                     , false ]  ,
        [ Dimmer10                    , '>'   , Number5                     , true  ]  ,
        [ Dimmer10                    , '>'   , Number20                    , false ]  ,

        # NumberItem's state vs DimmerItem's state
        [ Number10.state              , 'eql?', Dimmer10.state              , false ]  ,
        [ Number10.state              , '=='  , Dimmer10.state              , true  ]  ,
        [ Number5.state               , '=='  , Dimmer10.state              , false ]  ,
        [ Number5.state               , '!='  , Dimmer10.state              , true  ]  ,
        [ Number10.state              , '!='  , Dimmer10.state              , false ]  ,

        # DimmerItem vs Ruby Numeric
        [ Dimmer10                    , 'eql?', 10                          , false ]  ,
        [ Dimmer10                    , '=='  , 10                          , true  ]  ,
        [ Dimmer10                    , '=='  , 10.1                        , false ]  ,
        [ Dimmer10                    , '!='  , 2                           , true  ]  ,
        [ Dimmer10                    , '!='  , 10                          , false ]  ,

        [ Dimmer10                    , '<'   , 20                          , true  ]  ,
        [ Dimmer10                    , '<'   , 5                           , false ]  ,
        [ Dimmer10                    , '>'   , 5                           , true  ]  ,
        [ Dimmer10                    , '>'   , 20                          , false ]  ,

        # DimmerItem vs OnOffType
        [ Dimmer10                    , 'eql?', ON                          , false ]  ,
        [ Dimmer10                    , '=='  , ON                          , true  ]  ,
        [ Dimmer10                    , '=='  , OFF                         , false ]  ,
        [ Dimmer10                    , '!='  , ON                          , false ]  ,
        [ Dimmer10                    , '!='  , OFF                         , true  ]  ,

        # Ruby Numeric vs DimmerItem
        [ 10                          , 'eql?', Dimmer10                    , false ]  ,
        [ 10                          , '=='  , Dimmer10                    , true  ]  ,
        [ 10.1                        , '=='  , Dimmer10                    , false ]  ,
        [ 2                           , '!='  , Dimmer10                    , true  ]  ,
        [ 10                          , '!='  , Dimmer10                    , false ]  ,

        [ 5                           , '<'   , Dimmer10                    , true  ]  ,
        [ 20                          , '<'   , Dimmer10                    , false ]  ,
        [ 11                          , '>'   , Dimmer10                    , true  ]  ,
        [ 5                           , '>'   , Dimmer10                    , false ]  ,

        # NumberItem with UoM vs another
        [ Number10C                   , 'eql?', Number10C2                  , false ]  ,
        [ Number10C                   , '=='  , Number10C2                  , true  ]  ,
        [ Number10C                   , '!='  , Number10C2                  , false ]  ,

        # NumberItem with UoM vs String
        [ Number10C                   , 'eql?', '10 °C'                     , false ]  ,
        [ Number10C                   , '>'   , '4 °F'                      , true  ]  ,
        [ Number10C                   , '=='  , '10 °C'                     , true  ]  ,

        # NumberItem with UoM vs Integer
        [ Number10C                   , 'eql?', 10                          , false ]  ,
        [ Number10C                   , '>'   , 3                           , true  ]  ,
        [ Number10C                   , '=='  , 10                          , true  ]  ,
        [ NumberLux                   , '<'   , 100                         , false ]  ,
        [ 100                         , '>'   , NumberLux                   , false ]  ,

        # NumberItem with UoM vs QuantityType
        [ Number10C                   , 'eql?', QuantityType.new('10°C')    , false ]  ,
        [ Number10C                   , '=='  , QuantityType.new('10°C')    , true  ]  ,
        [ Number10C                   , '=='  , QuantityType.new('10°F')    , false ]  ,
        [ Number10C                   , '=='  , QuantityType.new('50°F')    , true  ]  ,
        [ Number10C                   , '!='  , QuantityType.new('10°F')    , true  ]  ,
        [ Number10C                   , '!='  , QuantityType.new('10.1°C')  , true  ]  ,
        [ Number10C                   , '!='  , QuantityType.new('50°F')    , false ]  ,

        [ Number10C                   , '>'   , QuantityType.new('5°C')     , true  ]  ,
        [ Number10C                   , '>'   , QuantityType.new('10°F')    , true  ]  ,
        [ Number10C                   , '>'   , QuantityType.new('50°F')    , false ]  ,
        [ Number5C                    , '<'   , QuantityType.new('10°C')    , true  ]  ,
        [ Number20C                   , '<'   , QuantityType.new('10°C')    , false ]  ,
        [ Number5C                    , '<'   , QuantityType.new('50°F')    , true  ]  ,

        # QuantityType vs NumberItem with UoM
        [ QuantityType.new('10°C')    , 'eql?', Number10C                   , false ]  ,
        [ QuantityType.new('10°C')    , '=='  , Number10C                   , true  ]  ,
        [ QuantityType.new('50°F')    , '=='  , Number10C                   , true  ]  ,
        [ QuantityType.new('10°F')    , '=='  , Number10C                   , false ]  ,
        [ QuantityType.new('10°C')    , '=='  , Number20C                   , false ]  ,


        [ QuantityType.new('10°F')    , '!='  , Number10C                   , true  ]  ,
        [ QuantityType.new('10.1°C')  , '!='  , Number10C                   , true  ]  ,
        [ QuantityType.new('50°F')    , '!='  , Number10C                   , false ]  ,
        [ QuantityType.new('10°C')    , '!='  , Number10C                   , false ]  ,

        [ QuantityType.new('50°C')    , '>'   , Number10C                   , true  ]  ,
        [ QuantityType.new('10°F')    , '>'   , Number10C                   , false ]  ,
        [ QuantityType.new('50°F')    , '>'   , Number10C                   , false ]  ,
        [ QuantityType.new('10°C')    , '<'   , Number20C                   , true  ]  ,
        [ QuantityType.new('10°C')    , '<'   , Number5C                    , false ]  ,
        [ QuantityType.new('50°F')    , '<'   , Number20C                   , true  ]  ,

        # NumberItem vs PercentType
        [ Number10                    , 'eql?', PercentType.new(10)         , false ]  ,
        [ Number10                    , '=='  , PercentType.new(10)         , true  ]  ,
        [ Number5                     , '=='  , PercentType.new(10)         , false ]  ,
        [ Number5                     , '!='  , PercentType.new(10)         , true  ]  ,
        [ Number10                    , '!='  , PercentType.new(10)         , false ]  ,

        [ Number5                     , '<'   , PercentType.new(10)         , true  ]  ,
        [ Number20                    , '<'   , PercentType.new(10)         , false ]  ,
        [ Number20                    , '>'   , PercentType.new(10)         , true  ]  ,
        [ Number5                     , '>'   , PercentType.new(10)         , false ]  ,

        # PercentType vs NumberItem
        [ PercentType.new(10)         , 'eql?', Number10                    , false ]  ,
        [ PercentType.new(10)         , '=='  , Number10                    , true  ]  ,
        [ PercentType.new(10)         , '=='  , Number5                     , false ]  ,
        [ PercentType.new(10)         , '!='  , Number5                     , true  ]  ,
        [ PercentType.new(10)         , '!='  , Number10                    , false ]  ,

        [ PercentType.new(10)         , '<'   , Number20                    , true  ]  ,
        [ PercentType.new(10)         , '<'   , Number5                     , false ]  ,
        [ PercentType.new(10)         , '>'   , Number5                     , true  ]  ,
        [ PercentType.new(10)         , '>'   , Number20                    , false ]  ,

        # NumberItem vs DecimalType
        [ Number10                    , 'eql?', DecimalType.new(10)         , false ]  ,
        [ Number10                    , '=='  , DecimalType.new(10)         , true  ]  ,
        [ Number5                     , '=='  , DecimalType.new(10)         , false ]  ,
        [ Number5                     , '!='  , DecimalType.new(10)         , true  ]  ,
        [ Number10                    , '!='  , DecimalType.new(10)         , false ]  ,

        [ Number5                     , '<'   , DecimalType.new(10)         , true  ]  ,
        [ Number20                    , '<'   , DecimalType.new(10)         , false ]  ,
        [ Number20                    , '>'   , DecimalType.new(10)         , true  ]  ,
        [ Number5                     , '>'   , DecimalType.new(10)         , false ]  ,

        # DecimalType vs NumberItem
        [ DecimalType.new(10)         , 'eql?', Number10                    , false ]  ,
        [ DecimalType.new(10)         , '=='  , Number10                    , true  ]  ,
        [ DecimalType.new(10)         , '=='  , Number5                     , false ]  ,
        [ DecimalType.new(10)         , '!='  , Number5                     , true  ]  ,
        [ DecimalType.new(10)         , '!='  , Number10                    , false ]  ,

        [ DecimalType.new(10)         , '<'   , Number20                    , true  ]  ,
        [ DecimalType.new(10)         , '<'   , Number5                     , false ]  ,
        [ DecimalType.new(10)         , '>'   , Number5                     , true  ]  ,
        [ DecimalType.new(10)         , '>'   , Number20                    , false ]  ,

        # PercentType vs DecimalType
        [ PercentType.new(10)         , 'eql?', DecimalType.new(10)         , false ]  ,
        [ PercentType.new(10)         , '=='  , DecimalType.new(10)         , true  ]  ,
        [ PercentType.new(10)         , '=='  , DecimalType.new(5)          , false ]  ,
        [ PercentType.new(10)         , '!='  , DecimalType.new(5)          , true  ]  ,
        [ PercentType.new(10)         , '!='  , DecimalType.new(10)         , false ]  ,

        [ PercentType.new(10)         , '<'   , DecimalType.new(20)         , true  ]  ,
        [ PercentType.new(10)         , '<'   , DecimalType.new(5)          , false ]  ,
        [ PercentType.new(10)         , '>'   , DecimalType.new(5)          , true  ]  ,
        [ PercentType.new(10)         , '>'   , DecimalType.new(20)         , false ]  ,

        # DecimalType vs PercentType
        [ DecimalType.new(10)         , 'eql?', PercentType.new(10)         , false ]  ,
        [ DecimalType.new(10)         , '=='  , PercentType.new(10)         , true  ]  ,
        [ DecimalType.new(10)         , '=='  , PercentType.new(5)          , false ]  ,
        [ DecimalType.new(10)         , '!='  , PercentType.new(5)          , true  ]  ,
        [ DecimalType.new(10)         , '!='  , PercentType.new(10)         , false ]  ,

        [ DecimalType.new(10)         , '<'   , PercentType.new(20)         , true  ]  ,
        [ DecimalType.new(10)         , '<'   , PercentType.new(5)          , false ]  ,
        [ DecimalType.new(10)         , '>'   , PercentType.new(5)          , true  ]  ,
        [ DecimalType.new(10)         , '>'   , PercentType.new(20)         , false ]  ,

        # QuantityType vs String with UoM
        [ QuantityType.new('10°C')    , '=='  , '10°C'                      , true  ]  ,
        [ QuantityType.new('50°F')    , '=='  , '10°C'                      , true  ]  ,
        [ QuantityType.new('10°F')    , '=='  , '10°C'                      , false ]  ,
        [ QuantityType.new('10°C')    , '=='  , '20°C'                      , false ]  ,

        [ QuantityType.new('10°F')    , '!='  , '10°C'                      , true  ]  ,
        [ QuantityType.new('10.1°C')  , '!='  , '10°C'                      , true  ]  ,
        [ QuantityType.new('50°F')    , '!='  , '10°C'                      , false ]  ,
        [ QuantityType.new('10°C')    , '!='  , '10°C'                      , false ]  ,

        [ QuantityType.new('50°C')    , '>'   , '10°C'                      , true  ]  ,
        [ QuantityType.new('10°F')    , '>'   , '10°C'                      , false ]  ,
        [ QuantityType.new('50°F')    , '>'   , '10°C'                      , false ]  ,
        [ QuantityType.new('10°C')    , '<'   , '20°C'                      , true  ]  ,
        [ QuantityType.new('10°C')    , '<'   , '5°C'                       , false ]  ,
        [ QuantityType.new('50°F')    , '<'   , '20°C'                      , true  ]  ,

        # String with UoM vs QuantityType
        [ '10°C'                      , '=='  , QuantityType.new('10°C')    , true  ]  ,
        [ '10°C'                      , '=='  , QuantityType.new('50°F')    , true  ]  ,
        [ '10°C'                      , '=='  , QuantityType.new('10°F')    , false ]  ,
        [ '20°C'                      , '=='  , QuantityType.new('10°C')    , false ]  ,
        [ '10°C'                      , '!='  , QuantityType.new('10°F')    , true  ]  ,
        [ '10°C'                      , '!='  , QuantityType.new('10.1°C')  , true  ]  ,
        [ '10°C'                      , '!='  , QuantityType.new('50°F')    , false ]  ,
        [ '10°C'                      , '!='  , QuantityType.new('10°C')    , false ]  ,
        [ '10°C'                      , '<'   , QuantityType.new('50°C')    , true  ]  ,
        [ '10°C'                      , '<'   , QuantityType.new('10°F')    , false ]  ,
        [ '10°C'                      , '<'   , QuantityType.new('50°F')    , false ]  ,
        [ '20°C'                      , '>'   , QuantityType.new('10°C')    , true  ]  ,
        [ '5°C'                       , '>'   , QuantityType.new('10°C')    , false ]  ,
        [ '20°C'                      , '>'   , QuantityType.new('50°F')    , true  ]  ,

        # PercentType vs PercentType
        [ PercentType.new(10)         , 'eql?', PercentType.new(10)         , true  ]  ,
        [ PercentType.new(10)         , '=='  , PercentType.new(10)         , true  ]  ,
        [ PercentType.new(10)         , '=='  , PercentType.new(1)          , false ]  ,
        [ PercentType.new(10)         , '!='  , PercentType.new(1)          , true  ]  ,
        [ PercentType.new(10)         , '!='  , PercentType.new(10)         , false ]  ,
        [ PercentType.new(10)         , '<'   , PercentType.new(10.1)       , true  ]  ,
        [ PercentType.new(10)         , '<'   , PercentType.new(5)          , false ]  ,
        [ PercentType.new(10)         , '>'   , PercentType.new(5)          , true  ]  ,
        [ PercentType.new(10)         , '>'   , PercentType.new(10.1 )      , false ]  ,

        # PercentType vs Ruby Numeric
        [ PercentType.new(10)         , 'eql?', 10                          , false ]  ,
        [ PercentType.new(10)         , '=='  , 10                          , true  ]  ,
        [ PercentType.new(10)         , 'eql?', 1                           , false ]  ,
        [ PercentType.new(10)         , '=='  , 1                           , false ]  ,
        [ PercentType.new(10)         , '!='  , 1                           , true  ]  ,
        [ PercentType.new(10)         , '!='  , 10                          , false ]  ,
        [ PercentType.new(10)         , '<'   , 10.1                        , true  ]  ,
        [ PercentType.new(10)         , '<'   , 5                           , false ]  ,
        [ PercentType.new(10)         , '>'   , 5                           , true  ]  ,
        [ PercentType.new(10)         , '>'   , 10.1                        , false ]  ,

        # Ruby Numeric vs PercentType
        [ 10                          , '=='  , PercentType.new(10)         , true  ]  ,
        [ 10                          , '=='  , PercentType.new(5)          , false ]  ,
        [ 10                          , '!='  , PercentType.new(5)          , true  ]  ,
        [ 10                          , '!='  , PercentType.new(10)         , false ]  ,
        [ 10.5                        , '<'   , PercentType.new(20)         , true  ]  ,
        [ 10                          , '<'   , PercentType.new(5)          , false ]  ,
        [ 10                          , '>'   , PercentType.new(5)          , true  ]  ,
        [ 10                          , '>'   , PercentType.new(10)         , false ]  ,

        # DecimalType vs DecimalType
        [ DecimalType.new(10)         , 'eql?', DecimalType.new(10)         , true  ]  ,
        [ DecimalType.new(10)         , '=='  , DecimalType.new(10)         , true  ]  ,
        [ DecimalType.new(10)         , 'eql?', DecimalType.new(1)          , false ]  ,
        [ DecimalType.new(10)         , '=='  , DecimalType.new(1)          , false ]  ,
        [ DecimalType.new(10)         , '!='  , DecimalType.new(1)          , true  ]  ,
        [ DecimalType.new(10)         , '!='  , DecimalType.new(10)         , false ]  ,
        [ DecimalType.new(10)         , '<'   , DecimalType.new(10.1)       , true  ]  ,
        [ DecimalType.new(10)         , '<'   , DecimalType.new(5)          , false ]  ,
        [ DecimalType.new(10)         , '>'   , DecimalType.new(5)          , true  ]  ,
        [ DecimalType.new(10)         , '>'   , DecimalType.new(10.1)       , false ]  ,

        # DecimalType vs Ruby Numeric
        [ DecimalType.new(10)         , 'eql?', 10                          , false ]  ,
        [ DecimalType.new(10)         , '=='  , 10                          , true  ]  ,
        [ DecimalType.new(10)         , '=='  , 1                           , false ]  ,
        [ DecimalType.new(10)         , '!='  , 1                           , true  ]  ,
        [ DecimalType.new(10)         , '!='  , 10                          , false ]  ,
        [ DecimalType.new(10)         , '<'   , 10.1                        , true  ]  ,
        [ DecimalType.new(10)         , '<'   , 5                           , false ]  ,
        [ DecimalType.new(10)         , '>'   , 5                           , true  ]  ,
        [ DecimalType.new(10)         , '>'   , 10.1                        , false ]  ,

        # Ruby Numeric vs DecimalType
        [ 10                          , '=='  , DecimalType.new(10)         , true  ]  ,
        [ 10                          , '=='  , DecimalType.new(5)          , false ]  ,
        [ 10                          , '!='  , DecimalType.new(5)          , true  ]  ,
        [ 10                          , '!='  , DecimalType.new(10)         , false ]  ,
        [ 10.5                        , '<'   , DecimalType.new(20)         , true  ]  ,
        [ 10                          , '<'   , DecimalType.new(5)          , false ]  ,
        [ 10                          , '>'   , DecimalType.new(5)          , true  ]  ,
        [ 10                          , '>'   , DecimalType.new(10)         , false ]  ,

        # DateTimeItem
        [ DateOne                     , '<'   , DateTwo                     , true  ]  ,
        [ DateOne                     , '<='  , '2021-02-09'                , true  ]  ,
        [ DateOne                     , '>'   , Time.now                    , false ]  ,
        [ DateOne                     , '=='  , '2021-01-01T00:00:00+00:00' , true  ]  ,
        [ DateOne                     , '!='  , '2021-01-01T00:00:00+01:00' , true  ]  ,

        [ DateTwo                     , '<'   , DateOne                     , false ]  ,
        [ '2021-02-09'                , '>='  , DateOne                     , true  ]  ,
        [ Time.now                    , '>'   , DateOne                     , true  ]  ,
        [ '2021-01-01T00:00:00+00:00' , '=='  , DateOne                     , true  ]  ,
        [ '2021-01-01T00:00:00+01:00' , '!='  , DateOne                     , true  ]  ,

        # DateTimeType
        [ DateTimeType.parse('2021-01-01T00:00:00+00:00'), '<'  , DateTimeType.parse('2021-02-01T12:00:00+00:00'), true  ]  ,
        [ DateTimeType.parse('2021-01-01T00:00:00+00:00'), '<'  , DateTwo, true  ]  ,
        [ DateTimeType.parse('2021-01-01T00:00:00+00:00'), '<=' , '2021-02-09'                , true  ]  ,
        [ DateTimeType.parse('2021-01-01T00:00:00+00:00'), '>'  , Time.now                    , false ]  ,
        [ DateTimeType.parse('2021-01-01T00:00:00+00:00'), '==' , '2021-01-01T00:00:00+00:00' , true  ]  ,
        [ DateTimeType.parse('2021-01-01T00:00:00+00:00'), '!=' , '2021-01-01T00:00:00+01:00' , true  ]  ,

        [ DateTimeType.parse('2021-02-01T12:00:00+00:00'), '<'  , DateTimeType.parse('2021-01-01T00:00:00+00:00'), false ]  ,
        [ DateTwo                     , '<'   , DateTimeType.parse('2021-01-01T00:00:00+00:00'), false ]  ,
        [ '2021-02-09'                , '>='  , DateTimeType.parse('2021-01-01T00:00:00+00:00'), true  ]  ,
        [ Time.now                    , '>'   , DateTimeType.parse('2021-01-01T00:00:00+00:00'), true  ]  ,
        [ '2021-01-01T00:00:00+00:00' , '=='  , DateTimeType.parse('2021-01-01T00:00:00+00:00'), true  ]  ,
        [ '2021-01-01T00:00:00+01:00' , '!='  , DateTimeType.parse('2021-01-01T00:00:00+00:00'), true  ]  ,

        # HSBType
        [ HSBType.new(0, 100, 100)    , '=='  , Color                       , true  ]  ,
        [ HSBType.new(0, 100, 100)    , '!='  , Color                       , false ]  ,
        [ Color                       , '=='  , HSBType.new(0, 100, 100)    , true  ]  ,
        [ Color                       , '!='  , HSBType.new(0, 100, 100)    , false ]  ,
        [ Color                       , '=='  , 100                         , true  ]  ,
        [ Color                       , '=='  , ON                          , true  ]  ,

        # Rollershutters
        [ ShutterTwo                  , '=='  , 50                          , true  ]  ,
        [ ShutterOne                  , '<'   , 50                          , true  ]  ,
        [ ShutterOne                  , '>'   , ShutterTwo                  , false ]  ,
        [ 50                          , '=='  , ShutterTwo                  , true  ]  ,
        [ 50                          , '<'   , ShutterOne                  , false ]  ,
        [ ShutterTwo                  , '>'   , ShutterOne                  , true  ]  ,

        # Groups
        [ Temperatures                , '<'   , Temperatures.max            , true  ]  ,
        [ Temperatures                , '>'   , 0                           , true  ]  ,
        [ Temperatures                , '>'   , '0 °C'                      , true  ]  ,
        [ Switches                    , '=='  , ON                          , false ]  ,
        [ Switches                    , '=='  , OFF                         , true  ]  ,
        [ Switches                    , '=='  , SwitchTwo                   , true  ]  ,
        [ Switches                    , '=='  , SwitchOne                   , false ]  ,
        [ Contacts                    , '=='  , OPEN                        , true  ]  ,
        [ Contacts                    , '=='  , CLOSED                      , false ]  ,
        [ Dates                       , '<'   , Time.now                    , true  ]  ,
        [ Dates                       , '>'   , DateOne                     , true  ]  ,
        [ Dates                       , '=='  , DateTwo                     , true  ]  ,
        [ Dates                       , '=='  , DateOne                     , false ]  ,
        [ Dates                       , '=='  , TimeOfDay.noon              , true  ]  ,
        [ Shutters                    , '=='  , UP                          , false ]  ,
        [ Shutters                    , '=='  , DOWN                        , true  ]  ,
        [ ShuttersPos                 , '=='  , 50                          , true  ]  ,
        [ ShuttersPos                 , '<'   , 20                          , false ]  ,

        [ Temperatures.max            , '<'   , Temperatures                , false ]  ,
        [ '0 °C'                      , '<'   , Temperatures                , true  ]  ,
        [ ON                          , '=='  , Switches                    , false ]  ,
        [ OFF                         , '=='  , Switches                    , true  ]  ,
        [ SwitchTwo                   , '=='  , Switches                    , true  ]  ,
        [ SwitchOne                   , '=='  , Switches                    , false ]  ,
        [ OPEN                        , '=='  , Contacts                    , true  ]  ,
        [ CLOSED                      , '=='  , Contacts                    , false ]  ,
        [ Time.now                    , '<'   , Dates                       , false ]  ,
        [ DateOne                     , '>'   , Dates                       , false ]  ,
        [ DateTwo                     , '=='  , Dates                       , true  ]  ,
        [ DateOne                     , '=='  , Dates                       , false ]  ,
        [ TimeOfDay.noon              , '=='  , Dates                       , true  ]  ,
        [ UP                          , '=='  , Shutters                    , false ]  ,
        [ DOWN                        , '=='  , Shutters                    , true  ]  ,
        [ 50                          , '=='  , ShuttersPos                 , true  ]  ,
        [ 20                          , '<'   , ShuttersPos                 , true  ]  ,

        # Enums
        [ NULL                        , '=='  , NULL                        , true  ]  ,
        [ NULL                        , '=='  , UNDEF                       , false ]  ,
        [ NULL                        , '=='  , ON                          , false ]  ,
        [ NULL                        , '=='  , OFF                         , false ]  ,
        [ NULL                        , '=='  , UP                          , false ]  ,
        [ NULL                        , '=='  , REFRESH                     , false ]  ,
        [ UNDEF                       , '=='  , NULL                        , false ]  ,
        [ UNDEF                       , '=='  , UNDEF                       , true  ]  ,
        [ UNDEF                       , '=='  , ON                          , false ]  ,
        [ UNDEF                       , '=='  , OFF                         , false ]  ,
        [ UNDEF                       , '=='  , UP                          , false ]  ,
        [ UNDEF                       , '=='  , REFRESH                     , false ]  ,
        [ REFRESH                     , '=='  , NULL                        , false ]  ,
        [ REFRESH                     , '=='  , UNDEF                       , false ]  ,
        [ REFRESH                     , '=='  , ON                          , false ]  ,
        [ REFRESH                     , '=='  , OFF                         , false ]  ,
        [ REFRESH                     , '=='  , UP                          , false ]  ,
        [ REFRESH                     , '=='  , REFRESH                     , true  ]  ,
        [ ON                          , '=='  , NULL                        , false ]  ,
        [ ON                          , '=='  , UNDEF                       , false ]  ,
        [ ON                          , '=='  , ON                          , true  ]  ,
        [ ON                          , '=='  , OFF                         , false ]  ,
        [ ON                          , '=='  , UP                          , false ]  ,
        [ ON                          , '=='  , REFRESH                     , false ]  ,
        [ OFF                         , '=='  , NULL                        , false ]  ,
        [ OFF                         , '=='  , UNDEF                       , false ]  ,
        [ OFF                         , '=='  , ON                          , false ]  ,
        [ OFF                         , '=='  , OFF                         , true  ]  ,
        [ OFF                         , '=='  , UP                          , false ]  ,
        [ OFF                         , '=='  , REFRESH                     , false ]  ,
        [ NULL                        , '!='  , NULL                        , false ]  ,
        [ NULL                        , '!='  , UNDEF                       , true  ]  ,
        [ NULL                        , '!='  , ON                          , true  ]  ,
        [ NULL                        , '!='  , OFF                         , true  ]  ,
        [ NULL                        , '!='  , UP                          , true  ]  ,
        [ NULL                        , '!='  , REFRESH                     , true  ]  ,
        [ UNDEF                       , '!='  , NULL                        , true  ]  ,
        [ UNDEF                       , '!='  , UNDEF                       , false ]  ,
        [ UNDEF                       , '!='  , ON                          , true  ]  ,
        [ UNDEF                       , '!='  , OFF                         , true  ]  ,
        [ UNDEF                       , '!='  , UP                          , true  ]  ,
        [ UNDEF                       , '!='  , REFRESH                     , true  ]  ,
        [ REFRESH                     , '!='  , NULL                        , true  ]  ,
        [ REFRESH                     , '!='  , UNDEF                       , true  ]  ,
        [ REFRESH                     , '!='  , ON                          , true  ]  ,
        [ REFRESH                     , '!='  , OFF                         , true  ]  ,
        [ REFRESH                     , '!='  , UP                          , true  ]  ,
        [ REFRESH                     , '!='  , REFRESH                     , false ]  ,
        [ ON                          , '!='  , NULL                        , true  ]  ,
        [ ON                          , '!='  , UNDEF                       , true  ]  ,
        [ ON                          , '!='  , ON                          , false ]  ,
        [ ON                          , '!='  , OFF                         , true  ]  ,
        [ ON                          , '!='  , UP                          , true  ]  ,
        [ ON                          , '!='  , REFRESH                     , true  ]  ,
        [ OFF                         , '!='  , NULL                        , true  ]  ,
        [ OFF                         , '!='  , UNDEF                       , true  ]  ,
        [ OFF                         , '!='  , ON                          , true  ]  ,
        [ OFF                         , '!='  , OFF                         , false ]  ,
        [ OFF                         , '!='  , UP                          , true  ]  ,
        [ OFF                         , '!='  , REFRESH                     , true  ]  ,

        [ (0..100)                    , '===' , ON                          , false ]  ,
        [ 50                          , '=='  , ON                          , false ]  ,
        [ ON                          , '===' , PercentType.new(50)         , true  ]  ,
      ]

      def test_to_s(test)
        left, operator, right, expected_result = test
        "#{left.class} (#{left}) #{operator} #{right.class} (#{right}) should be: #{expected_result}"
      end

      ok_count = 0
      failed_tests = []
      tests.each_with_index do |test, index|
        left, operator, right, expected_result = test
        logger.info(test_to_s(test))
        result = left.__send__(operator, right)
        if result == expected_result
          logger.info("#{index} Test OK")
          ok_count += 1
        else
          failed_tests << test
          logger.error("#{index} Test ERROR")
        end
      rescue => e
        failed_tests << test
        logger.error("#{index} Test ERROR")
        logger.error("#{e}: #{e.backtrace}")
      end

      if ok_count == tests.count
        logger.info("All tests passed")
      else
        logger.error("Some tests failed:")
        failed_tests.each { |test| logger.error(test_to_s(test)) }
      end
      logger.info("Total tests: #{tests.count}, passed: #{ok_count}, failed: #{tests.count - ok_count}")
      """
    When I deploy the rules file
    Then It should log "All tests passed" within 2 seconds
    And It should not log "Test ERROR" within 2 seconds
