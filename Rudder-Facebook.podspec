Pod::Spec.new do |s|
    s.name             = 'Rudder-Facebook'
    s.version          = '0.1.0-beta.1'
    s.summary          = 'Privacy and Security focused Segment-alternative. Facebook App Events Native SDK integration support.'
    
    s.description      = <<-DESC
    Rudder is a platform for collecting, storing and routing customer event data to dozens of tools. Rudder is open-source, can run in your cloud environment (AWS, GCP, Azure or even your data-centre) and provides a powerful transformation framework to process your event data on the fly.
    DESC
    
    s.homepage         = 'https://github.com/rudderlabs/rudder-integration-facebook-ios'
    s.license          = { :type => "Apache", :file => "LICENSE" }
    s.author           = { 'Rudderlabs' => 'arnab@rudderlabs.com' }
    s.source           = { :git => 'https://github.com/rudderlabs/rudder-integration-facebook-ios.git' }
    s.platform         = :ios, "9.0"
    
    s.ios.deployment_target = '8.0'
    
    s.source_files = 'Rudder-Facebook/Classes/**/*'
    
    s.dependency 'Rudder' , '1.0.1'
    s.dependency 'FacebookSDK'
end