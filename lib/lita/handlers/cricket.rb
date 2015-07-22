module Lita
  module Handlers
    class Cricket < Handler
      # Dependencies
      require 'json'
      require 'httparty'

      @@ENDPOINT = 'http://cricscore-api.appspot.com/csa'

      route(
        /cricket/i,
        :refresh_user
      )

      route(
        /^\(?cricket\)?$/i,
        :scores,
        help: {
          'cricket' => 'Display the scores for your matches',
        }
      )

      route(
        /^\(?cricket\)?\s+-s\s+(.*)$/i,
        :subscribe,
        help: {
          'cricket -s 743965' => 'Subscribe to match 743965'
        }
      )

      route(
        /^\(?cricket\)?\s+-u\s+(.*)$/i,
        :unsubscribe,
        help: {
          'cricket -u 743963' => 'Unsubscribe from match 743963'
        }
      )

      route(
        /^\(?cricket\)?\s+-l$/i,
        :list,
        help: {
          'cricket -l' => 'List matches to which you have subscribed'
        }
      )

      route(
        /^\(?cricket\)?\s+-f\s+(.*)$/i,
        :favourite,
        help: {
          'cricket -f Cromer Cricket Club' => 'Add a favourite team!'
        }
      )

      route(
        /^\(?cricket\)?\s+-r\s+(.*)$/i,
        :unfavourite,
        help: {
          'cricket -r Cromer Cricket Club' => 'Remove a favourite team!'
        }
      )

      def refresh_user(response)
        my_favourites = redis.get("#{response.user.id}-favourites")
        if my_favourites.nil?
          redis.set("#{response.user.id}-favourites",[].to_json)
          response.reply('I can give you live cricket updates! Type `help cricket` for more information.')
        elsif
          update_favourites(response.user)
        end
      end

      def scores(response)
        match = response.matches[0][0].to_i
        if match == 0
        elsif
          puts "Looking up #{match}"
          resp = HTTParty.get(@@ENDPOINT, query: { id: match })
          puts resp
          response.reply('some_information_from_the_api')
        end
      end

      def subscribe(response)
        match = response.matches[0][0].to_i
        my_matches = JSON.parse(redis.get("#{response.user.id}-subscriptions")) rescue my_matches = []
        my_matches << match
        my_matches.uniq!
        resp = redis.set("#{response.user.id}-subscriptions",my_matches)
        response.reply("Subscribed you to match ##{match}: #{resp}")
      end

      def unsubscribe(response)
        match = response.matches[0][0].to_i
        my_matches = JSON.parse(redis.get("#{response.user.id}-subscriptions")) rescue my_matches = []
        if my_matches.delete(match) == nil
          response.reply("You weren't subscribed to match ##{match}!")
        elsif
          resp = redis.set("#{response.user.id}-subscriptions",my_matches)
          response.reply("Unsubscribed you to match ##{match}: #{resp}")
        end
      end

      def list(response)
        resp = HTTParty.get(@@ENDPOINT)
        #TODO: parse this list and keep going!!!
        response.reply("There are #{resp.count} live matches on!")
        resp.each do |r|
          response.reply("#{r['t1']} vs #{r['t2']} (http://www.espncricinfo.com/c/engine/match/#{r['id']}.html)")
        end
      rescue
        response.reply("An error may have occured, or maybe there are no live matches")
      end

      def favourite(response)
      end

      def unfavourite(response)
      end

      def update_favourites(response)
      end



    end

    Lita.register_handler(Cricket)
  end
end
