Pod::Spec.new do |s|
  s.name         = "OnionsFramework"
  s.version      = "0.0.2"
  s.summary      = "OnionsFramework allows connection to the Onions DB for iOS/OSX"
  s.description  = "OnionsFramework is the backend framework that powers the Onions iOS app and other future OSX/iOS clients."

  s.homepage     = "https://onionsapp.github.io"
  s.license      = "MIT"
  s.author       = { "Ben Gordon" => "bgordon@curse.com" }

  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/onionsapp/Onions-SwiftFramework.git", :tag => s.version }

  s.source_files  = "Classes", "**/*.swift"

  s.dependency "RNCryptor"
  s.dependency "Parse"

end
