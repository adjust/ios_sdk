Pod::Spec.new do |s|
  s.name           = "Adjust"
  s.version        = "4.2.3"
  s.summary        = "This is the iOS SDK of adjust. You can read more about it at http://adjust.com."
  s.homepage       = "http://adjust.com"
  s.license        = { :type => 'MIT', :file => 'MIT-LICENSE' }
  s.author         = { "Christian Wellenbrock" => "welle@adjust.com" }
  s.source         = { :git => "https://github.com/adjust/ios_sdk.git", :tag => "v4.2.3" }
  s.platform       = :ios, '4.3'
  s.framework      = 'SystemConfiguration'
  s.weak_framework = 'AdSupport', 'iAd'
  s.source_files   = 'Adjust/*.{h,m}', 'Adjust/ADJAdditions/*.{h,m}'
  s.requires_arc   = true
end
