# frozen_string_literal: true

require "jekyll"
require_relative "version"

module MastodonSocial
  class Error < StandardError; end
end

def require_all(group)
  Dir[File.expand_path("#{group}/*.rb", __dir__)].each do |file|
    require file
  end
end

require_all "jekyll/commands"
require_all "jekyll/generators"
