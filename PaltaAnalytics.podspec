Pod::Spec.new do |spec|

  spec.name         = "PaltaAnalytics"
  spec.version      = "3.9.2"
  spec.summary      = "A short description of PaltaAnalytics."

  spec.homepage     = "https://github.com/Palta-Data-Platform/paltalib-eventschema-swift-sdk"

  spec.license      = "MIT"

  spec.author       = { "Vyacheslav Beltyukov" => "vyacheslav.beltyukov@palta.com" }

  spec.platform     = :ios
  spec.platform     = :ios, "14.0"

  spec.source       = { :git => "https://github.com/Palta-Data-Platform/paltalib-eventschema-swift-sdk.git", :tag => "#{spec.version}" }

  spec.source_files  = "Sources/Analytics/**/*.swift"
  
  spec.swift_version = '5.7.2'
  
  spec.dependency "PaltaCore", ">= 3.2.2"
  spec.dependency "PaltaAnalyticsModel", "= #{spec.version}"
  spec.dependency "PaltaAnalyticsPrivateModel", "= #{spec.version}"
  spec.dependency "PaltaAnalyticsWiring", "= #{spec.version}"

end
