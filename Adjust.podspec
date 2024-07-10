Pod::Spec.new do |s|
  s.name                    = "Adjust"
  s.module_name             = "AdjustSdk"
  s.version                 = "5.0.0"
  s.summary                 = "This is the iOS SDK of Adjust. You can read more about it at https://adjust.com."
  s.homepage                = "https://github.com/adjust/ios_sdk"
  s.license                 = { :type => 'MIT', :file => 'LICENSE' }
  s.author                  = { "Adjust" => "sdk@adjust.com" }
  s.source                  = { :git => "https://github.com/adjust/ios_sdk.git", :tag => "v#{s.version}" }
  s.ios.deployment_target   = '12.0'
  s.tvos.deployment_target  = '12.0'
  s.framework               = 'SystemConfiguration'
  s.ios.weak_framework      = 'AdSupport'
  s.tvos.weak_framework     = 'AdSupport'
  s.default_subspec         = 'Adjust'
  s.module_map              = 'ModuleMap/module.modulemap'

  s.subspec 'Adjust' do |ads|
    ads.source_files = 'Adjust/**/*.{h,m}'
    ads.public_header_files = 'Adjust/*.h', 'UmbrellaHeaders/sdk/*.h'
    ads.resource_bundle = {'Adjust' => ['Adjust/*.xcprivacy']}
    ads.header_dir = 'AdjustSdk'
    ads.dependency 'AdjustSignature', '3.18'
  end

  s.subspec 'AdjustWebBridge' do |wb|
    wb.source_files = 'Adjust/**/*.{h,m}', 'AdjustBridge/*.{h,m}', 'UmbrellaHeaders/webbridge/*.{h,m}'
    wb.public_header_files = 'Adjust/*.h', 'AdjustBridge/*.h', 'UmbrellaHeaders/webbridge/*.h'
    wb.resource_bundle = {'Adjust' => ['Adjust/*.xcprivacy']}
    wb.header_dir = 'AdjustSdk'
    wb.dependency 'AdjustSignature', '3.18'
    wb.ios.deployment_target = '12.0'
  end
end
