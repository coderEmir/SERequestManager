#
# Be sure to run `pod lib lint SERequestManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SERequestManager'
  s.version          = '0.1.0'
  s.summary          = 'swift network component'

  s.description      = 'A package for "AliyunOSSiOS" and "Alamofire" '

  s.homepage         = 'https://github.com/seeEmil/SERequestManager'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'seeEmil' => '864009759@qq.com' }
  s.source           = { :git => 'https://github.com/seeEmil/SERequestManager.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  
  s.swift_version = '5.0'
  
  s.source_files = 'SERequestManager/Classes/**/*'

  s.dependency 'AliyunOSSiOS', '~>2.10.8'
  s.dependency 'Alamofire', '~>5.4.1'
end
