platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

workspace 'SwiftList'

target 'SwiftList' do
  pod 'DifferenceKit'
end

target 'SwiftListTests' do
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.0'
    end
  end
end
