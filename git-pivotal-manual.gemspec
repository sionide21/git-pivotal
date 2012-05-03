Gem::Specification.new do |s|
  s.name = 'git-pivotal'
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ['Jeff Tucker', 'Sam Stokes']
  s.date = '2011-05-19'
  s.description = 'A collection of git utilities to ease integration with Pivotal Tracker'
  s.email = 'jeff@trydionel.com'
  s.executables = Dir['bin/*'].map{|f| File.basename f }
  s.extra_rdoc_files = [
    "LICENSE"
  ]
  s.files = Dir[
    "LICENSE",
    "Rakefile",
    "bin/*",
    "git-hooks/post-commit",
    "git-pivotal.gemspec",
    "lib/**",
    "lib/**/**",
    "readme.markdown"
  ]
  s.homepage = 'http://github.com/trydionel/git-pivotal'
  s.require_paths = ['lib']
  s.rubygems_version = '1.8.2'
  s.summary = 'A collection of git utilities to ease integration with Pivotal Tracker'

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<pivotal-tracker>, ["~> 0.3.1"])
    else
      s.add_dependency(%q<pivotal-tracker>, ["~> 0.3.1"])
    end
  else
    s.add_dependency(%q<pivotal-tracker>, ["~> 0.3.1"])
  end
end

