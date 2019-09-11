Pod::Spec.new do |s|
  s.name         = "Aho-Corasick"
  s.version      = "3.0"
  s.summary      = "🔍 Swift implementation of the Aho-Corasick algorithm for efficient String matching"
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }


  s.description  = <<-DESC
  This library is the Swift implementation of the afore-mentioned Aho-Corasick algorithm for efficient string matching. The algorithm is explained in great detail in the white paper written by Aho and Corasick. It supports matching several patterns at once, unicode word boundaris, case insensitive and diacritic insensitive searches.
                   DESC

  s.homepage         = 'https://github.com/fpg1503/Aho-Corasick-Swift'
  s.authors = { 'Francesco Perrotti-Garcia' => 'fpg1503@gmail.com' }
  s.source = { :git => 'https://github.com/fpg1503/Aho-Corasick-Swift.git', :tag => s.version }
  s.ios.deployment_target = '8.0'
  s.source_files = 'Source/**/*.swift'

end