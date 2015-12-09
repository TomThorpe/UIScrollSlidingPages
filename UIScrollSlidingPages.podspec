
Pod::Spec.new do |s|
  s.name             = "UIScrollSlidingPages"
  s.version          = "1.4"
  s.summary          = "This control allows you to add multiple view controllers and have them scroll horizontally, each with a smaller header view."

  s.homepage         = "https://github.com/TomThorpe/UIScrollSlidingPages"
  s.screenshots     = [
"https://raw.github.com/TomThorpe/UIScrollSlidingPages/1.4/Screenshots/1.png",
"https://raw.github.com/TomThorpe/UIScrollSlidingPages/1.4/Screenshots/4.png",
"https://raw.github.com/TomThorpe/UIScrollSlidingPages/1.4/Screenshots/uiscrollslidingpages.gif"
]
  s.license          = 'MIT'
  s.author           = { "Tom Thorpe" => "code@tomthorpe.co.uk" }
  s.source           = { :git => "https://github.com/TomThorpe/UIScrollSlidingPages.git", :tag => s.version.to_s }

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'UIScrollViewSlidingPages/Source/**/*.{h,m}'
  s.resource_bundles = {
    'UIScrollSlidingPages' => ['UIScrollViewSlidingPages/Source/Images/**/*.png']
  }
end
