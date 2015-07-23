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
        /^\(?cricket\)?\s+(\d+)/i,
        :score,
        help: {
          'cricket 743965' => 'Display the score for match 743965'
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
          'cricket -l' => 'List the current live matches'
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

      route(
        /^\(?cricket\)?\s+-i$/i,
        :info,
        help: {
          'cricket -i' => 'Display your favourites and subscriptions'
        }
      )

      def refresh_user(response)
        my_favourites = get_my_favourites(response)
        if my_favourites.empty?
          redis.set("#{response.user.id}-favourites",['Australia'].to_json)
          response.reply('I can give you live cricket updates! Type `help cricket` for more information.')
        elsif
          matches = get_list_of_live_matches
          matches.each do |m|
            unless ([ m['t1'], m['t2']] & my_favourites).empty?
              subscribe_to_match(response,m['id'])
            end
          end
        end
      end

      def scores(response)
        subs = get_my_subscriptions(response)
        subs.each do |match|
          get_match_score(response,match)
        end
      end

      def score(response)
        match = response.matches[0][0].to_i
        get_match_score(response,match)
      end

      def subscribe(response)
        match = response.matches[0][0].to_i
        subscribe_to_match(response,match)
      end

      def unsubscribe(response)
        match = response.matches[0][0].to_i
        subs = get_my_subscriptions(response)
        if subs.delete(match) == nil
          response.reply("You weren't subscribed to match #{match}!")
        else
          resp = set_my_subscriptions(response,subs)
          response.reply("Unsubscribed you to match #{match}: #{resp}")
        end
      end

      def list(response)
        resp = get_list_of_live_matches
        #TODO: parse this list and keep going!!!
        response.reply("There are #{resp.count} live matches on!")
        resp.each do |r|
          response.reply("#{r['t1']} vs #{r['t2']} (http://www.espncricinfo.com/c/engine/match/#{r['id']}.html)")
        end
      rescue
        response.reply("An error may have occured, or maybe there are no live matches")
      end

      def favourite(response)
        match = response.matches[0][0]
        favs = get_my_favourites(response)
        favs << match
        favs.uniq!
        resp = set_my_favourites(response,favs)
        response.reply("Added #{match} to your favourites: #{resp}")
      end

      def unfavourite(response)
        match = response.matches[0][0]
        favs = get_my_favourites(response)
        if favs.delete(match) == nil
          response.reply("#{match} wasn't in your favourite list!")
        else
          resp = set_my_favourites(response,favs)
          response.reply("Removed #{match} from your favourites: #{resp}")
        end
      end

      def info(response)
        subs = get_my_subscriptions(response)
        favs = get_my_favourites(response)
        response.reply("Subscriptions: #{subs.join(' | ')}")
        response.reply("Favourites: #{favs.join(' | ')}")
      end

      def get_my_subscriptions(response)
        JSON.parse(redis.get("#{response.user.id}-subscriptions")) rescue []
      end

      def set_my_subscriptions(response,subs)
        redis.set("#{response.user.id}-subscriptions",subs)
      end

      def get_my_favourites(response)
        JSON.parse(redis.get("#{response.user.id}-favourites")) rescue []
      end

      def set_my_favourites(response,favs)
        redis.set("#{response.user.id}-favourites",favs)
      end

      def get_list_of_live_matches
        HTTParty.get(@@ENDPOINT).parsed_response
      end

      def get_match_score(response,id)
        if id == 0
          Lita.logger.debug("Skipping a 0 match")
        elsif
          resp = HTTParty.get(@@ENDPOINT, query: { id: id })
          response.reply(resp.parsed_response[0]['de']) rescue Lita.logger.debug("Skipping a bad match")
        end
      end

      def subscribe_to_match(response,id)
        subs = get_my_subscriptions(response)
        if (subs && [id]).empty
          subs << id
          resp = set_my_subscriptions(response,subs)
          response.reply("Subscribed you to match #{id}: #{resp}")
        end
      end

    end

    Lita.register_handler(Cricket)
  end
end
