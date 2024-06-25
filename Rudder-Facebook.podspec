require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

facebook_sdk_version = '~> 17.0.2'
rudder_sdk_version = '~> 1.12'
deployment_target = '12.0'
facebook_app_events = 'FBSDKCoreKit'

Pod::Spec.new do |s|
    s.name             = 'Rudder-Facebook'
    s.version          = package['version']
    s.summary          = 'Privacy and Security focused Segment-alternative. Facebook App Events Native SDK integration support.'

    s.description      = <<-DESC
    Rudder is a platform for collecting, storing and routing customer event data to dozens of tools. Rudder is open-source, can run in your cloud environment (AWS, GCP, Azure or even your data-centre) and provides a powerful transformation framework to process your event data on the fly.
    DESC

    s.homepage         = 'https://github.com/rudderlabs/rudder-integration-facebook-ios'
    s.license          = { :type => "ELv2", :file => "LICENSE.md" }
    s.author           = { 'Rudderlabs' => 'arnab@rudderlabs.com' }
    s.source           = { :git => 'https://github.com/rudderlabs/rudder-integration-facebook-ios.git', :tag => "v#{s.version}" }
    s.platform         = :ios, "12.0"

    s.source_files = 'Rudder-Facebook/Classes/**/*'
    s.ios.deployment_target = deployment_target
    
    if defined?($FacebookSDKVersion)
      facebook_sdk_version = $FacebookSDKVersion
      Pod::UI.puts "#{s.name}: Using user specified Facebook SDK version '#{FacebookSDKVersion}'"
    else
      Pod::UI.puts "#{s.name}: Using default facebook SDK version '#{facebook_sdk_version}'"
    end

    if defined?($RudderSDKVersion)
      Pod::UI.puts "#{s.name}: Using user specified Rudder SDK version '#{$RudderSDKVersion}'"
      rudder_sdk_version = $RudderSDKVersion
    else
      Pod::UI.puts "#{s.name}: Using default Rudder SDK version '#{rudder_sdk_version}'"
    end
    
    s.dependency 'Rudder', rudder_sdk_version
    s.dependency facebook_app_events, facebook_sdk_version
end
