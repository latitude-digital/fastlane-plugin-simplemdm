require 'fastlane/action'
require_relative '../helper/simplemdm_helper'
require_relative "../../../../simplemdm"

module Fastlane
  module Actions
    module SharedValues
    end

    class UploadToSimplemdmAction < Action
      def self.run(params)
        SimpleMDM.api_key = (params[:api_key]).to_s

        data = File.open((params[:ipa_path]).to_s)

        app = SimpleMDM::App.find(params[:app_id])

        app.binary = data
        app.name = params[:name] if params[:name]

        UI.message("Uploading #{app.name} `#{params[:ipa_path]}` to SimpleMDM for app ID #{params[:app_id]} deploying to #{params[:deploy_to]}")

        app.save(params[:deploy_to])

        UI.message("Uploaded #{app.name} (#{app.bundle_identifier} #{app.version})")
      end

      def self.description
        "Upload IPA to Simple MDM"
      end

      def self.authors
        ["iotashan"]
      end

      def self.details
        # Optional:
        "When using SimpleMDM for iOS app distribution, this provides an automate way to send updates directly to SimpleMDM"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_name: "SIMPLEMDM_API_KEY", # The name of the environment variable
                                       description: "API Token for SimpleMDM"), # a short description of this parameter
          FastlaneCore::ConfigItem.new(key: :app_id,
                                       env_name: "SIMPLEMDM_APP_ID",
                                       description: "The SimpleMDM App ID that will be uploaded",
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :ipa_path,
                                       env_name: "SIMPLEMDM_IPA_PATH",
                                       description: "The the path to the IPA",
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find ipa file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: "SIMPLEMDM_APP_NAME", # The name of the environment variable
                                       optional: true,
                                       description: "The name that SimpleMDM will use to reference this app. If left blank, SimpleMDM will automatically set this to the app name specified by the binary"), # a short description of this parameter
          FastlaneCore::ConfigItem.new(key: :deploy_to,
                                       env_name: "SIMPLEMDM_DEPLOY_TO", # The name of the environment variable
                                       description: "Deploy the app to associated devices immediately after the app has been uploaded and processed. Possible values are none, outdated or all", # a short description of this parameter
                                       default_value: "none",
                                       verify_block: proc do |value|
                                          accepted_formats = ["none", "outdated", "all"]
                                          UI.user_error!("Only \"none\" \"outdated\" or \"all\" values are allowed, you provided \"#{value}\"") unless accepted_formats.include? value
                                        end)
        ]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
