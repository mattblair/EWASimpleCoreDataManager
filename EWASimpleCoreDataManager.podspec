Pod::Spec.new do |s|

  s.name         = "EWASimpleCoreDataManager"
  s.version      = "0.0.1"
  s.summary      = "A simple collection of Core Data boilerplate."

  s.description  = <<-DESC
                   This is probably not the Core Data manager you should be using.

                   See the README file for the reasons, and alternative resources.
                   DESC

  s.homepage     = "https://github.com/mattblair/EWASimpleCoreDataManager"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "Matt Blair" => "elsewisemedia@gmail.com" }
  s.social_media_url = "http://twitter.com/elsewisemedia"

  s.platform     = :ios, '6.0'

  s.source       = { :git => "https://github.com/mattblair/EWASimpleCoreDataManager.git", :tag => "0.0.1" }

  s.source_files = 'EWASimpleCoreDataManager/*.{h,m}'
  s.framework    = 'CoreData'
  s.requires_arc = true

end
