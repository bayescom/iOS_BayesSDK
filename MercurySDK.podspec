Pod::Spec.new do |s|
  s.name             = 'MercurySDK'
  s.version          = '3.3.5'
  
  s.ios.deployment_target = '10.0'
  s.platform     = :ios, "10.0" 
  s.requires_arc = true
  
  s.license          = { :type => 'MIT', :file => 'LICENSE' }

  s.summary          = 'bayescom iOS SDK'
  s.description      = <<-DESC
Blink倍联——免费透明的流量变现神器 
600+ 移动媒体选择的广告商业化管理工具，定制私有的移动媒体商业化解决方案。优质上游资源一网打尽，接入方式快速透明稳定。支持流量分发、渠道策略、精准投放、数据报表、排期管理、广告审核等全流程业务场景。
                       DESC

  s.homepage         = 'http://www.bayescom.com/'
  s.author           = { 'bayescom' => 'http://www.bayescom.com/' }
  s.source           = { :git => 'https://github.com/bayescom/MercurySDK.git', :tag => s.version.to_s }

  s.vendored_frameworks = 'MercurySDK/*.framework'
   
  s.user_target_xcconfig = {'OTHER_LDFLAGS' => ['-ObjC']}
   
  valid_archs = ['i386', 'armv7', 'x86_64', 'arm64']
  # bitcode
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO', 'VALID_ARCHS' => valid_archs.join(' '), 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'ENABLE_BITCODE' => 'NO', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.frameworks = 'UIKit', 'Foundation'
  
  s.xcconfig = {
    'VALID_ARCHS' =>  valid_archs.join(' '),
  }
end
