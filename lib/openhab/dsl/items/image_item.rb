# frozen_string_literal: true

require 'base64'
require 'pathname'
require 'net/http'
require 'marcel'

module OpenHAB
  module DSL
    module Items
      java_import org.openhab.core.library.items.ImageItem

      # Adds methods to core OpenHAB ImageItem type to make it more natural in
      # Ruby
      class ImageItem < GenericItem
        #
        # Update image from file
        #
        # @param [String] file location
        # @param [String] mime_type of image
        #
        #
        def update_from_file(file, mime_type: nil)
          file_data = File.binread(file)
          mime_type ||= Marcel::MimeType.for(Pathname.new(file)) || Marcel::MimeType.for(file_data)
          update_from_bytes(file_data, mime_type: mime_type)
        end

        #
        # Update image from image at URL
        #
        # @param [String] uri location of image
        #
        #
        def update_from_url(uri)
          logger.debug("Downloading image from #{uri}")
          response = Net::HTTP.get_response(URI(uri))
          mime_type = response['content-type']
          bytes = response.body
          mime_type ||= detect_mime_from_bytes(bytes: bytes)
          update_from_bytes(bytes, mime_type: mime_type)
        end

        #
        # Update image from image bytes
        #
        # @param [String] mime_type of image
        # @param [Object] bytes image data
        #
        #
        def update_from_bytes(bytes, mime_type: nil)
          mime_type ||= detect_mime_from_bytes(bytes: bytes)
          base_64_image = encode_image(mime_type: mime_type, bytes: bytes)
          update(base_64_image)
        end

        #
        # Get the mime type for the image item
        #
        # @return [String] mime type for image, e.g. image/png
        #
        def mime_type
          state&.mime_type
        end

        #
        # Get the bytes of the image
        #
        # @return [Array] Bytes that comprise the image
        #
        def bytes
          state&.get_bytes
        end

        private

        #
        # Encode image information in the format required by OpenHAB
        #
        # @param [String] mime_type for image
        # @param [Object] bytes image data
        #
        # @return [String] OpenHAB image format with image data Base64 encoded
        #
        def encode_image(mime_type:, bytes:)
          "data:#{mime_type};base64,#{Base64.strict_encode64(bytes)}"
        end

        #
        # Detect the mime type based on bytes
        #
        # @param [Array] bytes representing image data
        #
        # @return [String] mime type if it can be detected, nil otherwise
        #
        def detect_mime_from_bytes(bytes:)
          logger.trace('Detecting mime type from file image contents')
          Marcel::MimeType.for(bytes)
        end
      end
    end
  end
end
