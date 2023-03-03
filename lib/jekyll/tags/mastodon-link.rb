require 'mastodon-social'

module Jekyll
  class MastodonLinkTagBlock < Liquid::Block

    def render(context)
      text = super
      url = MastodonSocial.syndication_info(context["page"]["url"])
      "<a href='#{url}'>#{text}</a>"
    end
  end
end

Liquid::Template.register_tag('mastodon_social', Jekyll::MastodonLinkTagBlock)
