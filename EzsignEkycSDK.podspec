Pod::Spec.new do |s|
  s.name             = 'EzsignEkycSDK'
  s.version          = '1.0.0'
  s.summary          = 'Native iOS SDK for ezSign eKYC verification with Megvii FaceID Active Liveness.'
  s.description      = <<-DESC
    Provides an all-in-one eKYC verification flow for iOS including demographic
    data validation (NIK, full name, birth date), phone OTP verification, and
    native active liveness detection powered by Megvii FaceID LV5.
  DESC
  s.homepage         = 'https://github.com/FvorY/ezsign-ekyc-sdk-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Muhammad Ferdy Cahya Pratama' => '38639406+FvorY@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/FvorY/ezsign-ekyc-sdk-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.swift_versions   = ['5.9']

  s.source_files     = 'Sources/EzsignEkycSDK/**/*.swift'
  s.resources        = ['Resources/**/*']
  s.vendored_frameworks = 'Frameworks/MegLiveV5Detect.framework', 'Frameworks/MGFaceIDBaseKit.framework'
  s.frameworks       = 'UIKit', 'AVFoundation', 'CoreMedia', 'CoreMotion'
end
