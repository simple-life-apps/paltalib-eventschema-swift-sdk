Pod::Spec.new do |spec|

  spec.name         = "PaltaAnalyticsWiring"
  spec.version      = "3.9.1"
  spec.summary      = "A short description of PaltaAnalyticsWiring."

  spec.homepage     = "https://github.com/Palta-Data-Platform/paltalib-eventschema-swift-sdk"

  spec.license      = "MIT"

  spec.author       = { "Vyacheslav Beltyukov" => "vyacheslav.beltyukov@palta.com" }

  spec.platform     = :ios
  spec.platform     = :ios, "11.0"

  spec.source       = { :git => "https://github.com/Palta-Data-Platform/paltalib-eventschema-swift-sdk.git", :tag => "#{spec.version}" }

  spec.source_files  = "Sources/AnalyticsWiring/**/*.{h,m}"
  spec.public_header_files = "Sources/AnalyticsWiring/Public/*.{h,m}"

end
