module Jekyll
  module MastodonSocial
    class MastodonSetup < Jekyll::Command
      class << self
        def init_with_program(prog)
          prog.command(:authorize) do |c|
            c.syntax("authorize")
            c.description("Authorize jekyll to post to your account")
            c.action do |args, opts|
              puts "I do nothing"
            end
          end
        end

      end
    end
  end
end

