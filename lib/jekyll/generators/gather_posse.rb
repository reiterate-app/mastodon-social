require "debug"

module Jekyll
  module MastodonSocial
    class GatherPosse < Generator
      def generate(site)
        MastodonSocial.setup(site)
        for post in site.posts.docs
          # If we've never processed this post, add it to the db as unpublished
          MastodonSocial.mark_as_published(post, nil) unless MastodonSocial.mastodon_status[post.url]
        end
        MastodonSocial.save_config()
      end
    end
  end
end
