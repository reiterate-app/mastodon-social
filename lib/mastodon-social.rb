# frozen_string_literal: true

require "jekyll"
require_relative "version"
require 'nokogiri'

module Jekyll
  module MastodonSocial
    class Error < StandardError; end

    class << self

      attr_accessor :client_id, :client_secret, :bearer_token
      attr_reader :config, :site, :mastodon_status

      # Load state from cache dir. Setup cache dir if it doesn't exist
      def setup(site)
        @site = site
        @jekyll_config = site.config
        @config = @jekyll_config["mastodon-syndication"] || {}

        # Set up the cache folder & files
        setup_config
        cache_data = YAML.load_file(@mastodon_cachefile)
        @mastodon_status = cache_data[:posts]
        @bearer_token = cache_data[:bearer_token]
        @client_id = cache_data[:client_id]
        @client_secret = cache_data[:client_secret]

        @mastodon_client = Mastodon::REST::Client.new(base_url: @config["server"],
          bearer_token: @bearer_token)
      end

      def setup_config
        @cache_folder = @site.in_source_dir(@config["cache-folder"] || ".jekyll-cache")
        unless File.exist?(@cache_folder)
          Dir.mkdir(@cache_folder)
        end
        file = Jekyll.sanitized_path(@cache_folder, "mastodon.yml")
        File.open(file, "wb") { |f| f.puts YAML.dump(Hash.new) } unless File.exist? file
        @mastodon_cachefile = file
      end

      def save_config
        state = {
          posts: @mastodon_status || {},
          bearer_token: @bearer_token,
          client_id: @client_id,
          client_secret: @client_secret
        }
        File.open(@mastodon_cachefile, "wb") { |f|
          f.puts YAML.dump(state)
        }
      end

      # mastodon_status is one of:
      # nil: this post has not been sent to mastodon
      # true: This post has been sent as a status, but we have no url
      # url: The Mastodon URL for the status linking this post
      def mark_as_published(post, mastodon_status)
        if post.kind_of? String
          post_url = post
          excerpt = ''
          hashtags = nil
        else
          # Don't do anything with posts that are in _drafts
          return if post.path.include? '_drafts'

          post_url = post.url
          excerpt_html = post.data['excerpt'].to_s
          excerpt = Nokogiri::HTML(excerpt_html).text.strip
          hashtags = post.data['hashtags']
          hashtags = hashtags.split if hashtags.is_a? String
        end
        status = @mastodon_status[post_url]
        if status.nil?
          @mastodon_status[post_url] = { 
            mastodon_status: mastodon_status,
            excerpt: excerpt,
            hashtags: hashtags
          }
        else
          status[:mastodon_status] = mastodon_status
          @mastodon_status[post_url] = status
        end
      end

      def clear_status
        @mastodon_status = {}
      end

      def syndication_info(url)
        status = @mastodon_status[url]
        return nil unless (status.kind_of? Hash and status[:mastodon_status].kind_of? Hash)
        status[:mastodon_status]
      end
    end

  end
end

def require_all(group)
  Dir[File.expand_path("#{group}/*.rb", __dir__)].each do |file|
    require file
  end
end

require_all "jekyll/commands"
require_all "jekyll/generators"
require_all "jekyll/tags"

Jekyll::Hooks.register :site, :after_init do |site|
  Jekyll::MastodonSocial.setup(site)
end
