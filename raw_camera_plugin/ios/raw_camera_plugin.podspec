Pod::Spec.new do |s|
  s.name             = 'raw_camera_plugin'
  s.version          = '0.0.1'
  s.summary          = 'Plugin Flutter pour capture RAW (.dng)'
  s.description      = <<-DESC
Capture d’image RAW via AVCapturePhotoOutput en Objective-C.
  DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Yenam' => 'yenam@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*.{h,m}'
  s.public_header_files = 'Classes/*.h'
  s.dependency       'Flutter'
  s.platform         = :ios, '13.0'
  s.swift_version    = nil
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
end
