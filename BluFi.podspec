Pod::Spec.new do |s|
  s.name             = 'BluFi'
  s.version          = '1.0.0'
  s.license          = 'MIT'
  s.summary          = 'The ESP32 BluFi Library for iOS'
  s.homepage         = 'https://github.com/tuanpmt/BluFi.git'
  s.social_media_url = 'https://twitter.com/tuanpmt'
  s.authors          = { 'Tuan' => 'tuanpm@live.com' }
  s.source           = { :git => 'https://github.com/tuanpmt/BluFi.git', :tag => s.version }
  s.screenshot       = ''

  s.ios.deployment_target     = '8.0'
  s.osx.deployment_target     = '10.11'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target    = '9.0'

  s.ios.framework = 'Foundation'

  s.dependency 'AwaitKit', '~> 5.0.0'
  s.dependency 'BigInt', '~> 3.1'
  s.dependency 'CryptoSwift', '0.11.0'

  s.source_files = 'Sources/**/*.swift'
  s.requires_arc = true
end
