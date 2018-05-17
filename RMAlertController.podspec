Pod::Spec.new do |s|
  s.name = "RMAlertController"
  s.version = "0.0.2"
  s.summary = "A Swift implementation of custom iOS alerts and actionsheets."
  s.homepage = "https://github.com/intonarumori/RMAlertController"
  s.license = { :type => "MIT", :file => "LICENSE.md" }
  s.authors = "Daniel Langh"
  s.ios.deployment_target = "9.0"
  s.source = { :git => "https://github.com/intonarumori/RMAlertController.git", :branch => "master" }
  s.source_files = 'RMAlertController/*.swift'
end
