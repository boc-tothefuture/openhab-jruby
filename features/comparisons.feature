Feature: comparisons
  Rule language supports comparisons of different types

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And items:
      | type               | name       | label         | group | state |
      | Number             | Number5    | Number Five   |       | 5     |
      | Number             | Number10   | Number Ten    |       | 10    |
      | Number             | Number10A  | Number Ten A  |       | 10    |
      | Number             | Number20   | Number Twenty |       | 20    |
      | Number:Temperature | Number5C   | Number Five   |       | 5°C   |
      | Number:Temperature | Number10C  | Number Ten    |       | 10°C  |
      | Number:Temperature | Number10C2 | Number Ten    |       | 10°C  |
      | Number:Temperature | Number20C  | Number Twenty |       | 20°C  |
      | Dimmer             | Dimmer5    | Dimmer Five   |       | 5     |
      | Dimmer             | Dimmer10   | Dimmer Ten    |       | 10    |

  Scenario: Comparisons can be done against different types
    Given code in a rules file
      """
      java_import org.openhab.core.library.types.DecimalType
      java_import org.openhab.core.library.types.PercentType

      #comparison pairs
      tests = [
        # NumberItem vs NumberItem
        [ Number10                   , '==' , Number10A                  , true  ]  ,
        [ Number10                   , '==' , Number5                    , false ]  ,
        [ Number10                   , '!=' , Number5                    , true  ]  ,
        [ Number10                   , '!=' , Number10A                  , false ]  ,

        [ Number10                   , '<'  , Number20                   , true  ]  ,
        [ Number10                   , '<'  , Number5                    , false ]  ,
        [ Number10                   , '>'  , Number5                    , true  ]  ,
        [ Number10                   , '>'  , Number20                   , false ]  ,

        # NumberItem vs Ruby Numeric
        [ Number10                   , '==' , 10                         , true  ]  ,
        [ Number10                   , '==' , 1                          , false ]  ,
        [ Number10                   , '!=' , 1                          , true  ]  ,
        [ Number10                   , '!=' , 10                         , false ]  ,

        [ Number10                   , '<'  , 10.1                       , true  ]  ,
        [ Number10                   , '<'  , 5                          , false ]  ,
        [ Number10                   , '>'  , 5                          , true  ]  ,
        [ Number10                   , '>'  , 10.1                       , false ]  ,

        # Ruby Numeric vs NumberItem
        [ 10                         , '==' , Number10                   , true  ]  ,
        [ 10                         , '==' , Number5                    , false ]  ,
        [ 10                         , '!=' , Number5                    , true  ]  ,
        [ 10                         , '!=' , Number10                   , false ]  ,

        [ 10.5                       , '<'  , Number20                   , true  ]  ,
        [ 10                         , '<'  , Number5                    , false ]  ,
        [ 10                         , '>'  , Number5                    , true  ]  ,
        [ 10                         , '>'  , Number10                   , false ]  ,

        # NumberItem vs DimmerItem
        [ Number10                   , '==' , Dimmer10                   , true  ]  ,
        [ Number10                   , '==' , Dimmer5                    , false ]  ,
        [ Number10                   , '!=' , Dimmer5                    , true  ]  ,
        [ Number10                   , '!=' , Dimmer10                   , false ]  ,

        [ Number5                    , '<'  , Dimmer10                   , true  ]  ,
        [ Number10                   , '<'  , Dimmer5                    , false ]  ,
        [ Number10                   , '>'  , Dimmer5                    , true  ]  ,
        [ Number5                    , '>'  , Dimmer10                   , false ]  ,

        # DimmerItem vs NumberItem
        [ Dimmer10                   , '==' , Number10                   , true  ]  ,
        [ Dimmer10                   , '==' , Number5                    , false ]  ,
        [ Dimmer10                   , '!=' , Number5                    , true  ]  ,
        [ Dimmer10                   , '!=' , Number10                   , false ]  ,

        [ Dimmer10                   , '<'  , Number20                   , true  ]  ,
        [ Dimmer10                   , '<'  , Number5                    , false ]  ,
        [ Dimmer10                   , '>'  , Number5                    , true  ]  ,
        [ Dimmer10                   , '>'  , Number20                   , false ]  ,

        # NumberItem's state vs DimmerItem's state
        [ Number10.state             , '==' , Dimmer10.state             , true  ]  ,
        [ Number5.state              , '==' , Dimmer10.state             , false ]  ,
        [ Number5.state              , '!=' , Dimmer10.state             , true  ]  ,
        [ Number10.state             , '!=' , Dimmer10.state             , false ]  ,

        # DimmerItem vs Ruby Numeric
        [ Dimmer10                   , '==' , 10                         , true  ]  ,
        [ Dimmer10                   , '==' , 10.1                       , false ]  ,
        [ Dimmer10                   , '!=' , 2                          , true  ]  ,
        [ Dimmer10                   , '!=' , 10                         , false ]  ,

        [ Dimmer10                   , '<'  , 20                         , true  ]  ,
        [ Dimmer10                   , '<'  , 5                          , false ]  ,
        [ Dimmer10                   , '>'  , 5                          , true  ]  ,
        [ Dimmer10                   , '>'  , 20                         , false ]  ,

        # Ruby Numeric vs DimmerItem
        [ 10                         , '==' , Dimmer10                   , true  ]  ,
        [ 10.1                       , '==' , Dimmer10                   , false ]  ,
        [ 2                          , '!=' , Dimmer10                   , true  ]  ,
        [ 10                         , '!=' , Dimmer10                   , false ]  ,

        [ 5                          , '<'  , Dimmer10                   , true  ]  ,
        [ 20                         , '<'  , Dimmer10                   , false ]  ,
        [ 11                         , '>'  , Dimmer10                   , true  ]  ,
        [ 5                          , '>'  , Dimmer10                   , false ]  ,

        # NumberItem with UoM vs another
        [ Number10C                  , '==' , Number10C2                 , true  ]  ,
        [ Number10C                  , '!=' , Number10C2                 , false ]  ,

        # NumberItem with UoM vs QuantityType
        [ Number10C                  , '==' , QuantityType.new('10°C')   , true  ]  ,
        [ Number10C                  , '==' , QuantityType.new('10°F')   , false ]  ,
        [ Number10C                  , '==' , QuantityType.new('50°F')   , true  ]  ,
        [ Number10C                  , '!=' , QuantityType.new('10°F')   , true  ]  ,
        [ Number10C                  , '!=' , QuantityType.new('10.1°C') , true  ]  ,
        [ Number10C                  , '!=' , QuantityType.new('50°F')   , false ]  ,

        [ Number10C                  , '>'  , QuantityType.new('5°C')    , true  ]  ,
        [ Number10C                  , '>'  , QuantityType.new('10°F')   , true  ]  ,
        [ Number10C                  , '>'  , QuantityType.new('50°F')   , false ]  ,
        [ Number5C                   , '<'  , QuantityType.new('10°C')   , true  ]  ,
        [ Number20C                  , '<'  , QuantityType.new('10°C')   , false ]  ,
        [ Number5C                   , '<'  , QuantityType.new('50°F')   , true  ]  ,

        # QuantityType vs NumberItem with UoM
        [ QuantityType.new('10°C')   , '==' , Number10C                  , true  ]  ,
        [ QuantityType.new('50°F')   , '==' , Number10C                  , true  ]  ,
        [ QuantityType.new('10°F')   , '==' , Number10C                  , false ]  ,
        [ QuantityType.new('10°C')   , '==' , Number20C                  , false ]  ,


        [ QuantityType.new('10°F')   , '!=' , Number10C                  , true  ]  ,
        [ QuantityType.new('10.1°C') , '!=' , Number10C                  , true  ]  ,
        [ QuantityType.new('50°F')   , '!=' , Number10C                  , false ]  ,
        [ QuantityType.new('10°C')   , '!=' , Number10C                  , false ]  ,

        [ QuantityType.new('50°C')   , '>'  , Number10C                  , true  ]  ,
        [ QuantityType.new('10°F')   , '>'  , Number10C                  , false ]  ,
        [ QuantityType.new('50°F')   , '>'  , Number10C                  , false ]  ,
        [ QuantityType.new('10°C')   , '<'  , Number20C                  , true  ]  ,
        [ QuantityType.new('10°C')   , '<'  , Number5C                   , false ]  ,
        [ QuantityType.new('50°F')   , '<'  , Number20C                  , true  ]  ,

        # NumberItem vs PercentType
        [ Number10                   , '==' , PercentType.new(10)        , true  ]  ,
        [ Number5                    , '==' , PercentType.new(10)        , false ]  ,
        [ Number5                    , '!=' , PercentType.new(10)        , true  ]  ,
        [ Number10                   , '!=' , PercentType.new(10)        , false ]  ,

        [ Number5                    , '<'  , PercentType.new(10)        , true  ]  ,
        [ Number20                   , '<'  , PercentType.new(10)        , false ]  ,
        [ Number20                   , '>'  , PercentType.new(10)        , true  ]  ,
        [ Number5                    , '>'  , PercentType.new(10)        , false ]  ,

        # PercentType vs NumberItem
        [ PercentType.new(10)        , '==' , Number10                   , true  ]  ,
        [ PercentType.new(10)        , '==' , Number5                    , false ]  ,
        [ PercentType.new(10)        , '!=' , Number5                    , true  ]  ,
        [ PercentType.new(10)        , '!=' , Number10                   , false ]  ,

        [ PercentType.new(10)        , '<'  , Number20                   , true  ]  ,
        [ PercentType.new(10)        , '<'  , Number5                    , false ]  ,
        [ PercentType.new(10)        , '>'  , Number5                    , true  ]  ,
        [ PercentType.new(10)        , '>'  , Number20                   , false ]  ,

        # NumberItem vs DecimalType
        [ Number10                   , '==' , DecimalType.new(10)        , true  ]  ,
        [ Number5                    , '==' , DecimalType.new(10)        , false ]  ,
        [ Number5                    , '!=' , DecimalType.new(10)        , true  ]  ,
        [ Number10                   , '!=' , DecimalType.new(10)        , false ]  ,

        [ Number5                    , '<'  , DecimalType.new(10)        , true  ]  ,
        [ Number20                   , '<'  , DecimalType.new(10)        , false ]  ,
        [ Number20                   , '>'  , DecimalType.new(10)        , true  ]  ,
        [ Number5                    , '>'  , DecimalType.new(10)        , false ]  ,

        # DecimalType vs NumberItem
        [ DecimalType.new(10)        , '==' , Number10                   , true  ]  ,
        [ DecimalType.new(10)        , '==' , Number5                    , false ]  ,
        [ DecimalType.new(10)        , '!=' , Number5                    , true  ]  ,
        [ DecimalType.new(10)        , '!=' , Number10                   , false ]  ,

        [ DecimalType.new(10)        , '<'  , Number20                   , true  ]  ,
        [ DecimalType.new(10)        , '<'  , Number5                    , false ]  ,
        [ DecimalType.new(10)        , '>'  , Number5                    , true  ]  ,
        [ DecimalType.new(10)        , '>'  , Number20                   , false ]  ,

        # PercentType vs DecimalType
        [ PercentType.new(10)        , '==' , DecimalType.new(10)        , true  ]  ,
        [ PercentType.new(10)        , '==' , DecimalType.new(5)         , false ]  ,
        [ PercentType.new(10)        , '!=' , DecimalType.new(5)         , true  ]  ,
        [ PercentType.new(10)        , '!=' , DecimalType.new(10)        , false ]  ,

        [ PercentType.new(10)        , '<'  , DecimalType.new(20)        , true  ]  ,
        [ PercentType.new(10)        , '<'  , DecimalType.new(5)         , false ]  ,
        [ PercentType.new(10)        , '>'  , DecimalType.new(5)         , TRUE  ]  ,
        [ PercentType.new(10)        , '>'  , DecimalType.new(20)        , false ]  ,

        # DecimalType vs PercentType
        [ DecimalType.new(10)        , '==' , PercentType.new(10)        , true  ]  ,
        [ DecimalType.new(10)        , '==' , PercentType.new(5)         , false ]  ,
        [ DecimalType.new(10)        , '!=' , PercentType.new(5)         , true  ]  ,
        [ DecimalType.new(10)        , '!=' , PercentType.new(10)        , false ]  ,

        [ DecimalType.new(10)        , '<'  , PercentType.new(20)        , true  ]  ,
        [ DecimalType.new(10)        , '<'  , PercentType.new(5)         , false ]  ,
        [ DecimalType.new(10)        , '>'  , PercentType.new(5)         , TRUE  ]  ,
        [ DecimalType.new(10)        , '>'  , PercentType.new(20)        , false ]  ,

        # QuantityType vs String with UoM
        [ QuantityType.new('10°C')   , '==' , '10°C'                     , true  ]  ,
        [ QuantityType.new('50°F')   , '==' , '10°C'                     , true  ]  ,
        [ QuantityType.new('10°F')   , '==' , '10°C'                     , false ]  ,
        [ QuantityType.new('10°C')   , '==' , '20°C'                     , false ]  ,

        [ QuantityType.new('10°F')   , '!=' , '10°C'                     , true  ]  ,
        [ QuantityType.new('10.1°C') , '!=' , '10°C'                     , true  ]  ,
        [ QuantityType.new('50°F')   , '!=' , '10°C'                     , false ]  ,
        [ QuantityType.new('10°C')   , '!=' , '10°C'                     , false ]  ,

        [ QuantityType.new('50°C')   , '>'  , '10°C'                     , true  ]  ,
        [ QuantityType.new('10°F')   , '>'  , '10°C'                     , false ]  ,
        [ QuantityType.new('50°F')   , '>'  , '10°C'                     , false ]  ,
        [ QuantityType.new('10°C')   , '<'  , '20°C'                     , true  ]  ,
        [ QuantityType.new('10°C')   , '<'  , '5°C'                      , false ]  ,
        [ QuantityType.new('50°F')   , '<'  , '20°C'                     , true  ]  ,

        # String with UoM vs QuantityType
        [ '10°C'                     , '==' , QuantityType.new('10°C')   , true  ]  ,
        [ '10°C'                     , '==' , QuantityType.new('50°F')   , true  ]  ,
        [ '10°C'                     , '==' , QuantityType.new('10°F')   , false ]  ,
        [ '20°C'                     , '==' , QuantityType.new('10°C')   , false ]  ,
        [ '10°C'                     , '!=' , QuantityType.new('10°F')   , true  ]  ,
        [ '10°C'                     , '!=' , QuantityType.new('10.1°C') , true  ]  ,
        [ '10°C'                     , '!=' , QuantityType.new('50°F')   , false ]  ,
        [ '10°C'                     , '!=' , QuantityType.new('10°C')   , false ]  ,
        [ '10°C'                     , '<'  , QuantityType.new('50°C')   , true  ]  ,
        [ '10°C'                     , '<'  , QuantityType.new('10°F')   , false ]  ,
        [ '10°C'                     , '<'  , QuantityType.new('50°F')   , false ]  ,
        [ '20°C'                     , '>'  , QuantityType.new('10°C')   , true  ]  ,
        [ '5°C'                      , '>'  , QuantityType.new('10°C')   , false ]  ,
        [ '20°C'                     , '>'  , QuantityType.new('50°F')   , true  ]  ,

        # QuantityType vs Quantity
        [ QuantityType.new('10°C')   , '==' , Quantity.new('10°C')       , true  ]  ,
        [ QuantityType.new('50°F')   , '==' , Quantity.new('10°C')       , true  ]  ,
        [ QuantityType.new('10°F')   , '==' , Quantity.new('10°C')       , false ]  ,
        [ QuantityType.new('10°C')   , '==' , Quantity.new('20°C')       , false ]  ,
        [ QuantityType.new('10°F')   , '!=' , Quantity.new('10°C')       , true  ]  ,
        [ QuantityType.new('10.1°C') , '!=' , Quantity.new('10°C')       , true  ]  ,
        [ QuantityType.new('50°F')   , '!=' , Quantity.new('10°C')       , false ]  ,
        [ QuantityType.new('10°C')   , '!=' , Quantity.new('10°C')       , false ]  ,
        [ QuantityType.new('50°C')   , '>'  , Quantity.new('10°C')       , true  ]  ,
        [ QuantityType.new('10°F')   , '>'  , Quantity.new('10°C')       , false ]  ,
        [ QuantityType.new('50°F')   , '>'  , Quantity.new('10°C')       , false ]  ,
        [ QuantityType.new('10°C')   , '<'  , Quantity.new('20°C')       , true  ]  ,
        [ QuantityType.new('10°C')   , '<'  , Quantity.new('5°C' )       , false ]  ,
        [ QuantityType.new('50°F')   , '<'  , Quantity.new('20°C')       , true  ]  ,

        # Quantity vs QuantityType
        [ Quantity.new('10°C')       , '==' , QuantityType.new('10°C')   , true  ]  ,
        [ Quantity.new('10°C')       , '==' , QuantityType.new('50°F')   , true  ]  ,
        [ Quantity.new('10°C')       , '==' , QuantityType.new('10°F')   , false ]  ,
        [ Quantity.new('20°C')       , '==' , QuantityType.new('10°C')   , false ]  ,
        [ Quantity.new('10°C')       , '!=' , QuantityType.new('10°F')   , true  ]  ,
        [ Quantity.new('10°C')       , '!=' , QuantityType.new('10.1°C') , true  ]  ,
        [ Quantity.new('10°C')       , '!=' , QuantityType.new('50°F')   , false ]  ,
        [ Quantity.new('10°C')       , '!=' , QuantityType.new('10°C')   , false ]  ,
        [ Quantity.new('10°C')       , '<'  , QuantityType.new('50°C')   , true  ]  ,
        [ Quantity.new('10°C')       , '<'  , QuantityType.new('10°F')   , false ]  ,
        [ Quantity.new('10°C')       , '<'  , QuantityType.new('50°F')   , false ]  ,
        [ Quantity.new('20°C')       , '>'  , QuantityType.new('10°C')   , true  ]  ,
        [ Quantity.new('5°C' )       , '>'  , QuantityType.new('10°C')   , false ]  ,
        [ Quantity.new('20°C')       , '>'  , QuantityType.new('50°F')   , true  ]  ,


        # PercentType vs Ruby Numeric
        [ PercentType.new(10)        , '==' , 10                         , true  ]  ,
        [ PercentType.new(10)        , '==' , 1                          , false ]  ,
        [ PercentType.new(10)        , '!=' , 1                          , true  ]  ,
        [ PercentType.new(10)        , '!=' , 10                         , false ]  ,
        [ PercentType.new(10)        , '<'  , 10.1                       , true  ]  ,
        [ PercentType.new(10)        , '<'  , 5                          , false ]  ,
        [ PercentType.new(10)        , '>'  , 5                          , true  ]  ,
        [ PercentType.new(10)        , '>'  , 10.1                       , false ]  ,

        # Ruby Numeric vs PercentType
        [ 10                         , '==' , PercentType.new(10)        , true  ]  ,
        [ 10                         , '==' , PercentType.new(5)         , false ]  ,
        [ 10                         , '!=' , PercentType.new(5)         , true  ]  ,
        [ 10                         , '!=' , PercentType.new(10)        , false ]  ,
        [ 10.5                       , '<'  , PercentType.new(20)        , true  ]  ,
        [ 10                         , '<'  , PercentType.new(5)         , false ]  ,
        [ 10                         , '>'  , PercentType.new(5)         , true  ]  ,
        [ 10                         , '>'  , PercentType.new(10)        , false ]  ,

        # DecimalType vs Ruby Numeric
        [ DecimalType.new(10)        , '==' , 10                         , true  ]  ,
        [ DecimalType.new(10)        , '==' , 1                          , false ]  ,
        [ DecimalType.new(10)        , '!=' , 1                          , true  ]  ,
        [ DecimalType.new(10)        , '!=' , 10                         , false ]  ,
        [ DecimalType.new(10)        , '<'  , 10.1                       , true  ]  ,
        [ DecimalType.new(10)        , '<'  , 5                          , false ]  ,
        [ DecimalType.new(10)        , '>'  , 5                          , true  ]  ,
        [ DecimalType.new(10)        , '>'  , 10.1                       , false ]  ,

        # Ruby Numeric vs DecimalType
        [ 10                         , '==' , DecimalType.new(10)        , true  ]  ,
        [ 10                         , '==' , DecimalType.new(5)         , false ]  ,
        [ 10                         , '!=' , DecimalType.new(5)         , true  ]  ,
        [ 10                         , '!=' , DecimalType.new(10)        , false ]  ,
        [ 10.5                       , '<'  , DecimalType.new(20)        , true  ]  ,
        [ 10                         , '<'  , DecimalType.new(5)         , false ]  ,
        [ 10                         , '>'  , DecimalType.new(5)         , true  ]  ,
        [ 10                         , '>'  , DecimalType.new(10)        , false ]  ,

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
