Pod::Spec.new do |s|
  s.name             = 'MercurySDK'
  s.version          = '4.6.5'
  s.summary          = 'bayescom iOS SDK'
  s.description      = <<-DESC
Blink倍联——免费透明的流量变现神器 
600+ 移动媒体选择的广告商业化管理工具，定制私有的移动媒体商业化解决方案。优质上游资源一网打尽，接入方式快速透明稳定。支持流量分发、渠道策略、精准投放、数据报表、排期管理、广告审核等全流程业务场景。
                       DESC
  
  s.homepage         = 'http://www.bayescom.com/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'bayescom' => 'http://www.bayescom.com/' }
  s.source           = { :git => 'https://github.com/bayescom/iOS_BayesSDK.git', :tag => s.version.to_s }

  s.platform     = :ios, "10.0"
  s.frameworks   = 'StoreKit', 'CoreTelephony', 'AdSupport', 'SystemConfiguration', 'AVFoundation'
  s.vendored_frameworks = 'MercurySDK/*.xcframework'
   
  s.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }
  #s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.xcconfig = {
          'OTHER_LDFLAGS' => '-ObjC'
      }
  
end
