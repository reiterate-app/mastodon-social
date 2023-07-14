# Mastodon::Social

A Jekyll plugin to create links to Mastodon for your posts.

## Installation

In your `Gemfile` add:
```ruby
 group :jekyll_plugins do
   # (other jekyll plugins)
   gem 'mastodon-api'
 end
```

## Usage

The plugin will add a new `mastodon` command to your jekyll setup:
```sh
$ be jekyll help
jekyll 3.9.2 -- Jekyll is a blog-aware, static site generator in Ruby

Usage:

  jekyll <subcommand> [options]

...

Subcommands:
  ...
  mastodon              Connect your blog with the Fediverse
$
```

Running `jekyll mastodon help` shows the subcommands:
```sh
jekyll mastodon [command]

Commands:
  setup:     Initial setup authorizing this plugin to post to your account
  authorize: Enter your password to authorize this plugin to post to your Mastodon account
  mark:      Mark all posts as published (to Mastodon)
  post:      Publish any new posts to Mastodon
  clean:     Erase all cached mastodon data
```

To use the plugin, you need to add a Mastodon tag somewhere in your page layout. Then use the `setup` and `authorize`
commands to link the plugin to your Mastodon account. Those are all one-time actions.

Whenever you rebuild your blog, you will then need to run the `post` command to send a new status post to Mastodon
with a link to your new entry.

### Mastodon Link

The plugin creates a new tag called `{% mastodon_social %}` You can add that tag to any page and it will create
a link to the Mastodon status post for this page (assuming it exists). To put a text anchor for the link, add text in 
the block, like so:
```html
{% mastodon_social %}
Boost this on Mastodon!
{% end_mastodon_social %}
```

### Setup and Authorization

Next, you need to tell the plugin which Mastodon instance you use as your home instance. It will connect there
to make the new status posts. In your `_config.yml` file, add this section:

```yaml
mastodon-syndication:
  server: https://your.mastodon-server.org
```

Once you have the gem installed and your config set up, run:
```
jekyll mastodon setup
```
This establishes the plugin as an application on your Mastodon instance.

Next, run:
```
jekyll mastodon authorize
```
This will prompt you for your Mastodon password, to authorize the plugin to post on your behalf. The plugin does
not save your password anywhere; however, it does save the token it uses to login. It's saved in 
`.jekyll-cache/mastodon.yml`. You should protect this; in theory anyone who has that token can use it to post
mastodon toots as you. You can see the token by loggin in to to Mastodon, then going to 
Preferences > Account > Authorized Apps. You can revoke the token if it is compromised, but then you will need
to redo the setup and authorization steps again. As long as you don't revoke the token, it's permanent and
you don't need to run the setup or authorization again.

### Posting to Mastodon

There are three commands used to sync your blog with mastodon: mark, clear, and post. For the most part, you
will only use post.

```
jekyll mastodon post
```
will sync your mastodon account and your blog. The plugin keeps track of every post that's been sent to Mastodon.
When you issue the `post` command, it checks for new posts on your blog and makes a toot for each one. That means
you can run `post` again and if you haven't made any new posts since last time, it won't do anything.

```
jekyll mastodon clear
```
This will cause the plugin to forget all the Mastodon posts its made. The next time you run `post` it will send
everything. Unless your blog is new you probably don't want to do this.

```
jekyll mastodon mark
```
This will mark every post on your blog as having been sent. If you have a lot of posts on your blog you will want
to do this before your very first sync; otherwise, the plugin will sent a toot for every one of your old posts (and
probably hit a rate limit).

### Chicken and Egg Problem

There's one issue with posting to Mastodon. When you have a link in your toot like the ones the plugin creates,
Mastodon will visit the link to create a Link Card. This is a nicely-formatted card with things like a title,
description, and even an image if you have the Open Graph metadata in your post. However, Mastodon can't generate
the card if your post doesn't exist yet (obviously).

This leads to a chicken-and-egg problem. The jekyll plugin that renders links to your mastodon post won't render
properly if the post isn't there on mastodon, but the Mastodon post won't have its Link Card if the post isn't
there yet. Each one needs the other to exist.

If you aren't using the `mastodon_social` tag in your layout, this isn't a problem. You can post a link
every time you build your blog by adding one step into your normal posting routine:

1. Create a post and build your blog with `jekyll build`
2. Make your new post visible online.
3. Post it to Mastodon with `jekyll mastodon post`

However, if you're using the `mastodon_social` tag to create links to your mastodon toot (so people can click it
and boost your post) then you'll need to build your blog *twice*:

1. Create a post and build your blog with `jekyll build`
2. Make your new post visible online (so the link card will render properly)
3. Post it to Mastodon with `jekyll mastodon post`
4. Build your blog again with `jekyll build`. This build will have the proper link.
5. Make the new build visible.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/reiterate-app/mastodon-social.
