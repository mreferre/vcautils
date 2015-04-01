Gem::Specification.new do |s|
  s.name        = 'vcautils'
  s.version     = '0.8'
  s.executables << 'vca'
  s.executables << 'vchs'
  s.executables << 'compute'
  s.date        = '2015-09-08'
  s.summary     = "VMware vCloud Air Utilities"
  s.description = "A set of tools to programmatically access VMware vCloud Air"
  
  s.required_ruby_version = '>= 1.9.3'
  s.add_runtime_dependency 'httparty', '~> 0.13.3'
  s.add_runtime_dependency 'xml-fu', '~> 0.2.0'
  s.add_runtime_dependency 'awesome_print', '~> 1.6', '>= 1.6.1'
  s.add_runtime_dependency 'gon-sinatra', '~> 0.1.2'
  s.add_runtime_dependency 'json', '~> 1.8', '>= 1.8.2'
  s.add_runtime_dependency 'sinatra', '~> 1.4', '>= 1.4.5'
  s.add_runtime_dependency 'rack-ssl', '~> 1.4', '>= 1.4.1'


  s.authors     = ["Massimo Re Ferrè"]
  s.email       = 'massimo@it20.info'
  s.files       = ["lib/vca.rb", "lib/vchs.rb", "lib/compute.rb", "lib/modules/vca-be.rb", "lib/modules/vchs-be.rb", "lib/modules/compute-be.rb"]
  s.homepage    = 'http://it20.info'
  s.license     = 'Apache License'
end
