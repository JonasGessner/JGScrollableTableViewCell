Pod::Spec.new do |s|

  s.name         	= "JGScrollableTableViewCell"
  s.version      	= "1.1"
  s.summary      	= "A UITableViewCell subclass with a scrollable content view."
  s.description  	= <<-DESC
JGScrollableTableViewCell is a simple and easy to use UITableViewCell subclass with a scrollable content view that exposes an accessory view when scrolled. The behavior is inspired by the iOS 7 mail app.
DESC
  s.homepage     	= "https://github.com/JonasGessner/JGScrollableTableViewCell"
  s.license      	= { :type => "MIT", :file => "LICENSE.txt" }
  s.author            	= "Jonas Gessner"
  s.social_media_url  	= "http://twitter.com/JonasGessner"
  s.platform     	= :ios, "5.0"
  s.source       	= { :git => "https://github.com/JonasGessner/JGScrollableTableViewCell.git", :tag => "v1.1" }
  s.source_files  	= "JGScrollableTableViewCell/*.{h,m}"
  s.frameworks 		= "Foundation", "UIKit", "CoreGraphics"
  s.requires_arc 	= true

end