# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'The Wave' do
  use_frameworks!

  # Firebase
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/RemoteConfig'
  pod 'FirebaseUI'
  pod 'TwitterCore', '~> 3.0.2.0'
  pod 'TwitterKit', '~> 3.2.1.0'

  pod 'GeoFire', :git => 'https://github.com/firebase/geofire-objc.git'

  # Else
  pod 'Crashlytics'
  pod 'SwiftKeychainWrapper'
  pod 'JSQMessagesViewController'
  pod 'OneSignal', '~> 2.0'
  pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :subspecs => ['Core', 'KSCrash']
  pod 'ReachabilitySwift', '~> 3'
  pod 'CropViewController'
  pod 'WVCheckMark'
  pod 'Lightbox'
  pod 'DottedLineView'

  target 'The Wave Tests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Firebase'
  end

end

target 'OneSignalNotificationServiceExtension' do
  use_frameworks!
  pod 'OneSignal', '~> 2.0'
end
