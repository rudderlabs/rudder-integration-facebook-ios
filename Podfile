workspace 'RudderFacebook.xcworkspace'
use_frameworks!
inhibit_all_warnings!
platform :ios, '9.0'

def shared_pods
    pod 'Rudder', :path => '~/Documents/Rudder/RudderStack-Cocoa/'
end

target 'SampleiOSObjC' do
    project 'Examples/SampleiOSObjC/SampleiOSObjC.xcodeproj'
    shared_pods
    pod 'Rudder-Facebook', :path => '.'
end

target 'RudderFacebook' do
    project 'RudderFacebook.xcodeproj'
    shared_pods
    pod 'FBSDKCoreKit', '12.0.2'
end
