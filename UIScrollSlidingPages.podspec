Pod::Spec.new do |s|
	s.name         = "UIScrollSlidingPages"
	s.version      = "1.3.1"
	s.summary      = "This control allows you to add multiple view controllers and have them scroll horizontally, each with a smaller header view."
	
	s.homepage     = "https://github.com/TomThorpe/UIScrollSlidingPages"
	s.license      = 'MIT'
	s.author       = { "Tom Thorpe" => "code@tomthorpe.co.uk" }

	s.source       = { :git => "https://github.com/toursprung/TSMessages.git", :tag => "#{s.version}"}

	s.platform     = :ios, '6.0'
	s.source_files = 'Classes', 'UIScrollViewSlidingPages/Source/**/*.{h,m}'
	s.resources = "UIScrollViewSlidingPages/Source/Images/**/*.png"
	s.requires_arc = true
end