Pod::Spec.new do |s|
  s.name                    = "Adjust"
  s.module_name             = "AdjustSdk"
  s.version                 = "5.0.1"
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

  s.subspec 'Adjust' do |adj|
    adj.source_files        = 'Adjust/**/*.{h,m}', 'UmbrellaHeaders/sdk/*.{h,m}'
    adj.public_header_files = 'Adjust/*.h', 'UmbrellaHeaders/sdk/*.h'
    adj.exclude_files       = 'Adjust/include/**/*.h'
    adj.resource_bundle     = {'Adjust' => ['Adjust/*.xcprivacy']}
    adj.header_dir          = 'AdjustSdk'
    adj.dependency          'AdjustSignature', '~> 3.18'
  end

  s.subspec 'AdjustWebBridge' do |awb|
    awb.source_files          = 'Adjust/**/*.{h,m}', 'AdjustBridge/*.{h,m}', 'UmbrellaHeaders/webbridge/*.{h,m}'
    awb.public_header_files   = 'Adjust/*.h', 'AdjustBridge/*.h', 'UmbrellaHeaders/webbridge/*.h'
    awb.exclude_files         = ['Adjust/include/**/*.h', 'AdjustBridge/include/**/*.h']
    awb.resource_bundle       = {'Adjust' => ['Adjust/*.xcprivacy']}
    awb.header_dir            = 'AdjustSdk'
    awb.ios.deployment_target = '12.0'
    awb.dependency            'AdjustSignature', '~> 3.18'
  end
end
