#
# Be sure to run `pod lib lint BackingStore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BackingStore'
  s.version          = '0.1.2'
  s.summary          = 'A framework that automatically handles perfect batch updates in table views and collection views.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A set of components that model some data which is to be displayed in a `UICollectionView` or `UITableView`.  When that data changes, these components automatically calculate the changes necessary to perform a smooth, performant batch update.  This includes inserted sections, inserted index paths, deleted sections, deleted indexpaths and moved indx paths.  What this means is that you never have to call reloadData() ever again, and every change you make to the contents of a table or collection view will be perfectly animated. Pretty cool, ain't it?
                       DESC

  s.homepage         = 'https://github.com/patricklynch/BackingStore'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'patricklynch' => 'pdlynch@gmail.com' }
  s.source           = { :git => 'https://github.com/patricklynch/BackingStore.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'BackingStore/Classes/**/*'
  s.swift_version = '4.2'
  
  # s.resource_bundles = {
  #   'BackingStore' => ['BackingStore/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
