Pod::Spec.new do |s|
  s.name = "RMAlertController"
  s.version = "0.0.1"
  s.summary = "A Swift implementation of custom iOS alerts and actionsheets."
  s.homepage = "https://github.com/intonarumori/RMAlertController"
  s.license = { :type => "MIT", :file => "LICENSE.md" }
  s.authors = "Daniel Langh"
  s.ios.deployment_target = "8.0"
  s.source = { :git => "https://github.com/intonarumori/RMAlertController.git", :tag => "v0.0.1" }
  s.source_files = 'RMAlertController/*.swift'
  s.dependency = 'OAStackView'
end