# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'ThePost' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Collection View custom scrolling
  pod 'UPCarouselFlowLayout', :git => 'https://github.com/SirArkimedes/UPCarouselFlowLayout.git'

  # Firebase
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Crash'
  pod 'FirebaseUI'

  # Fabric
  pod 'Crashlytics'

  # SwiftKeychainWrapper
  pod 'SwiftKeychainWrapper'

  # JSQMessagesViewController
  pod 'JSQMessagesViewController'

  # OneSignal
  pod 'OneSignal', '~> 2.0'

  target 'ThePostTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'OneSignalNotificationServiceExtension' do
  pod 'OneSignal', '~> 2.0'
end
