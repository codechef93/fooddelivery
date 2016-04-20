# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
platform :ios, '13.0'
use_frameworks!

def common_pods_for_target
     pod 'IQKeyboardManagerSwift'
     pod 'DZNEmptyDataSet'
     pod 'SVProgressHUD'
     pod 'Firebase/Core'
     pod 'Firebase/Auth'
     pod 'Firebase/Firestore'
     pod 'Firebase/Storage'
     pod 'CodableFirebase'
     pod 'Kingfisher'
     pod 'MessageKit'
     pod 'Firebase/Messaging'
     pod 'ReachabilitySwift'
     pod 'NotificationBannerSwift', '~> 3.0.0'
     pod 'Stripe'
end

target 'AditiAdmin' do
  common_pods_for_target
end

target 'AditiUser' do
  pod 'XLPagerTabStrip', '~> 9.0'
  common_pods_for_target
end

target 'AditiInternal' do
  pod 'XLPagerTabStrip', '~> 9.0'
  common_pods_for_target
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
