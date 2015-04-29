Pod::Spec.new do |s|
  s.name         = "JLNRSideBarController"
  s.version      = "0.0.1"
  s.summary      = "UITabController replacement that uses a side menu on iPad & iPhone 6 Plus"

  s.description  = <<-DESC
                   TODO
                   DESC

  s.homepage     = "https://github.com/jlnr/JLNRMenuController"
  s.license      = "MIT"
  s.author       = { "Julian Raschke" => "julian@raschke.de" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/jlnr/JLNRMenuController.git", :tag => "v1.0.0" }
  s.source_files = "Classes", "Classes/**/*.{h,m}"
  s.requires_arc = true
end
