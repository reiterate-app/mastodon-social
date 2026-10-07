require 'net/http'
require 'uri'
require 'json'

module Jekyll
  module MastodonSocial
    # Minimal Mastodon REST client covering the calls this plugin makes.
    # Replaces the mastodon-api gem, which is unmaintained and pins http ~> 4.0
    class Client
      class Error < StandardError; end

      def initialize(base_url:, bearer_token: nil)
        @base_url = base_url
        @bearer_token = bearer_token
      end

      # Returns the new status as a Hash, including 'id' and 'url'
      def create_status(text)
        post('/api/v1/statuses', status: text)
      end

      # Returns the registered app as a Hash, including 'client_id' and 'client_secret'
      def create_app(name, website, scopes)
        post('/api/v1/apps', client_name: name, website: website, scopes: scopes,
          redirect_uris: 'urn:ietf:wg:oauth:2.0:oob')
      end

      private

      def post(path, params)
        uri = URI.join(@base_url, path)
        request = Net::HTTP::Post.new(uri)
        request['Authorization'] = "Bearer #{@bearer_token}" if @bearer_token
        request.set_form_data(params)
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
          http.request(request)
        end
        raise Error, "Mastodon returned #{response.code} for #{path}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      end
    end
  end
end
