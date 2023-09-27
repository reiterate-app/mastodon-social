# frozen_string_literal: true

require_relative "lib/version"

Gem::Specification.new do |spec|
  spec.name = "mastodon-social"
  spec.version = MastodonSocial::VERSION
  spec.authors = ["Michael Meckler"]
  spec.email = ["rattroupe@reiterate-app.com"]

  spec.summary = "Create links for a Jekyll blog that allow reposting on Mastodon"
  spec.description = "Add mastodon social links"
  spec.required_ruby_version = ">= 2.6.0"
  spec.add_runtime_dependency 'mastodon-api', '~> 2.0'
  spec.add_runtime_dependency 'http', '~> 4.4'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
