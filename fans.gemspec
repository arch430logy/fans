# frozen_string_literal: true

require_relative "lib/fans/version"

Gem::Specification.new do |spec|
  spec.name = "fans"
  spec.version = Fans::VERSION
  spec.authors = ["c"]
  spec.email = ["0xe0ffffgmail.com"]

  spec.summary = "fandom web"
  spec.description = "fandom web"
  spec.homepage = "https://github.com/arch430logy/fans"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "nokogiri", "~> 1.18.0"
  spec.add_dependency "http", "~> 5.2.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
