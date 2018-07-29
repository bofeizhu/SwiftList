Pod::Spec.new do |s|
  s.name         = "SwiftList"
  s.version      = "0.0.1"
  s.summary      = "A data-driven UICollectionView framework."
  s.description  = 'A data-driven UICollectionView framework for building fast and flexible lists.'
  s.homepage     = "https://github.com/zhubofei/SwiftList"
  s.license      = "MIT"
  s.author             = { "Bofei Zhu" => "zhu.bofei@gmail.com" }
  s.social_media_url   = "https://twitter.com/bofei_zhu"
  s.source       = { :git => "http://github.com/zhubofei/SwiftList.git", :tag => "#{s.version}" }
  s.source_files = 'Source/**/*.swift'
  s.platform     = :ios, "10.0"
  s.swift_version = '4.0'
end
