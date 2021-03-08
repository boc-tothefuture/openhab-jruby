Feature: image_item
  Image Item are supported

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And items:
      | type  | name  |
      | Image | Image |

  Scenario: Image item provides access to underlying raw type
    Given code in a rules file
      """
      Image.update "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEUAAACnej3aAAAAAXRSTlMAQObYZgAAAApJREFUCNdjYAAAAAIAAeIhvDMAAAAASUVORK5CYII="
      after 3.seconds do
        logger.info("Mime type: #{Image.mime_type}")
        logger.info("Number of bytes: #{Image.bytes.length}")
      end
      """
    When I deploy the rules file
    Then It should log "Mime type: image/png" within 10 seconds
    And It should log "Number of bytes: 95" within 10 seconds

  Scenario: Image can be updated with base64 encoding images
    Given code in a rules file
      """
      Image.update "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEUAAACnej3aAAAAAXRSTlMAQObYZgAAAApJREFUCNdjYAAAAAIAAeIhvDMAAAAASUVORK5CYII="
      after 3.seconds do
        logger.info("Mime type: #{Image.mime_type}")
        logger.info("Number of bytes: #{Image.bytes.length}")
      end
      """
    When I deploy the rules file
    Then It should log "Mime type: image/png" within 10 seconds
    And It should log "Number of bytes: 95" within 10 seconds

  Scenario Outline: Image can be updated with a byte array
    Given file "1x1.png" is in the system temp dir
    And a rule template:
      """
      require 'tmpdir'
      Image.update_from_bytes(<update_parameters>)
      after 3.seconds do
        logger.info("Mime type: #{Image.mime_type}")
        logger.info("Number of bytes: #{Image.bytes.length}")
      end
      """
    When I deploy the rules file
    Then It should log "Mime type: image/png" within 10 seconds
    And It should log "Number of bytes: 95" within 10 seconds
    Examples:
      | update_parameters                                                          |
      | IO.binread(File.join('<%=Dir.tmpdir%>','1x1.png')), mime_type: 'image/png' |
      | IO.binread(File.join('<%=Dir.tmpdir%>','1x1.png'))                         |


  Scenario Outline: Image can be updated with a file
    Given file "1x1.png" is in the system temp dir
    And a rule template:
      """
      require 'tmpdir'
      Image.update_from_file(<update_parameters>)
      after 3.seconds do
        logger.info("Mime type: #{Image.mime_type}")
        logger.info("Number of bytes: #{Image.bytes.length}")
      end
      """
    When I deploy the rules file
    Then It should log "Mime type: <mime_type>" within 10 seconds
    And It should log "Number of bytes: 95" within 10 seconds
    Examples:
      | update_parameters                                            | mime_type |
      | File.join('<%=Dir.tmpdir%>','1x1.png')                       | image/png |
      | File.join('<%=Dir.tmpdir%>','1x1.png'), mime_type: 'foo/bar' | foo/bar   |


  Scenario: Image can be updated with a URL
    Given code in a rules file
      """
      Image.update_from_url 'https://raw.githubusercontent.com/boc-tothefuture/openhab-jruby/main/features/assets/1x1.png'
      after 3.seconds do
        logger.info("Mime type: #{Image.mime_type}")
        logger.info("Number of bytes: #{Image.bytes.length}")
      end
      """
    When I deploy the rules file
    Then It should log "Mime type: image/png" within 10 seconds
    And It should log "Number of bytes: 95" within 10 seconds




