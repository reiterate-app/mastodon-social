require 'mastodon'
require 'io/console'
require 'net/http'
require 'uri'
require 'json'
require 'debug'

module Jekyll
  module MastodonSocial
    class MastodonSetup < Jekyll::Command
      class << self
        def init_with_program(prog)
          prog.command(:mastodon) do |c|
            c.syntax('mastodon')
            c.description("Connect your blog with the Fediverse")
            c.action do |args, opts|
              if args.empty?
                do_help
              else
                case args[0]
                when /setup/
                  create_client_id opts
                when /mark/
                  mark opts
                when /post/
                  post opts
                when /clean/
                  clean
                when /help/
                  do_help
                when /auth/
                  get_token
                else
                  puts "Error, try 'mastodon help'"
                end
              end
            end
          end
        end

        def create_client_id(options = {})
          client = get_client()
          app = client.create_app("jekyll-social", MastodonSocial.site.config["url"], 'read write')
          MastodonSocial.client_id = app.client_id
          MastodonSocial.client_secret = app.client_secret
          MastodonSocial.save_config()
        end

        def get_token
          puts "Enter your Mastodon credentials for the account you want to post to"
          print "Account email: "
          email = STDIN.cooked(&:gets).chomp
          print "Account password: "
          password = STDIN.noecho(&:gets).chomp

          client = get_client()
          auth_uri = URI.parse("#{MastodonSocial.config['server']}/oauth/token")
          Net::HTTP.start(auth_uri.host, auth_uri.port, :use_ssl => auth_uri.scheme == 'https') do |http|
            request = Net::HTTP::Post.new(auth_uri, 'Content-Type' => 'application/json')
            request.body = {
              'client_id': MastodonSocial.client_id,
              'client_secret': MastodonSocial.client_secret,
              'grant_type': 'password',
              'username': email,
              'password': password,
              'scope': 'read write'
            }.to_json
            response = http.request request
            json_response = JSON.parse(response.body)
            MastodonSocial.bearer_token = json_response['access_token']
          end
          MastodonSocial.save_config()
        end

        def mark(options = {})
          client = get_client()
          # Scan through all posts and see which ones need to be posted to Mastodon
          for post_url in MastodonSocial.mastodon_status.keys
            MastodonSocial.mark_as_published(post_url, true)
          end
          MastodonSocial.save_config()
        end

        def clean
          client = get_client()
          MastodonSocial.clear_status()
          MastodonSocial.save_config()          
        end

        def get_client(options = {})
          options = configuration_from_options(options)
          site = Jekyll::Site.new(options)
          MastodonSocial.setup(site)
          return Mastodon::REST::Client.new(base_url: MastodonSocial.config["server"], bearer_token: MastodonSocial.bearer_token)
        end

        # Look for any blog posts that haven't been sent to Mastodon, and post a status for each
        def post(options = {})
          client = get_client()
          for post_url, status in MastodonSocial.mastodon_status
            next if status[:mastodon_status]
            puts "Publishing #{post_url} to Mastodon"
            msg_text = "#{MastodonSocial.site.config["url"]}#{post_url}\n\n#{status[:excerpt]}"
            status_result = client.create_status(msg_text)
            new_status = {id: status_result.id, url: status_result.url}
            MastodonSocial.mark_as_published(post_url, new_status)
          end
          MastodonSocial.save_config()
        end
        
        def do_help
          puts <<-END_HELP
jekyll mastodon [command]

Commands:
  setup:     Initial setup authorizing this plugin to post to your account
  authorize: Enter your password to authorize this plugin to post to your Mastodon account
  mark:      Mark all posts as published (to Mastodon)
  post:      Publish any new posts to Mastodon
  clean:     Erase all cached mastodon data
          END_HELP
        end
      end
    end
  end
end

