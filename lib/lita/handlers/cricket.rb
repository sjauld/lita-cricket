module Lita
  module Handlers
    class Cricket < Handler
      # Version
      VERSION = '0.0.4'

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
        my_favourites = get_my_subscriptions(response,'favourite')
        if my_favourites.empty?
          set_my_subscriptions(response,['Australia'].to_json,'favourite')
          response.reply('I can give you live cricket updates! Type `help cricket` for more information.')
        else
          status, matches = get_list_of_live_matches
          if status == :success
            matches.each do |m|
              unless ([ m['t1'], m['t2']] & my_favourites).empty?
                subscribe_to(response,m['id'],'match')
              end
            end
          end
        end
      end

      def scores(response)
        subs = get_my_subscriptions(response,'match')
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
        subscribe_to(response,match,'match')
      end

      def unsubscribe(response)
        match = response.matches[0][0].to_i
        subs = get_my_subscriptions(response,'match')
        if subs.delete(match) == nil
          response.reply("You weren't subscribed to match #{match}!")
        else
          resp = set_my_subscriptions(response,subs,'match')
          response.reply("Unsubscribed you to match #{match}: #{resp}")
        end
      end

      def list(response)
        status, resp = get_list_of_live_matches
        if status == :success
          response.reply("There are #{resp.count} live matches on!")
          resp.each do |m|
            response.reply("#{m['t1']} vs #{m['t2']} (http://www.espncricinfo.com/c/engine/match/#{m['id']}.html)")
          end
        else
          Lita.logger.error(resp.inspect)
          response.reply("It looks like the API is down - #{resp.response.code}")
        end

      rescue => e
        response.reply("An error may have occured, or maybe there are no live matches")
      end

      def favourite(response)
        match = response.matches[0][0]
        subscribe_to(response,match,'favourite')
      end

      def unfavourite(response)
        match = response.matches[0][0]
        unsubscribe_to(response,match,'favourite')
      end

      def info(response)
        subs = get_my_subscriptions(response,'match')
        favs = get_my_subscriptions(response,'favourite')
        response.reply("Subscriptions: #{subs.join(' | ')}")
        response.reply("Favourites: #{favs.join(' | ')}")
      end

      def get_my_subscriptions(response,type)
        JSON.parse(redis.get("#{response.user.id}-#{type}")) rescue []
      end

      def set_my_subscriptions(response,subs,type)
        redis.set("#{response.user.id}-#{type}",subs)
      end

      def get_list_of_live_matches
        resp = HTTParty.get(@@ENDPOINT)
        if resp.response.code.to_i > 299 || resp.response.code.to_i < 200
          return :failure, resp
        else
          return :success, resp.parsed_response
        end
      end

      def get_match_score(response,id)
        if id == 0
          Lita.logger.debug("Skipping a 0 match")
        elsif
          resp = HTTParty.get(@@ENDPOINT, query: { id: id })
          response.reply(resp.parsed_response[0]['de']) rescue Lita.logger.debug("Skipping a bad match")
        end
      end

      def subscribe_to(response,id,type)
        subs = get_my_subscriptions(response,type)
        if (subs & [id]).empty?
          subs << id
          resp = set_my_subscriptions(response,subs,type)
          response.reply("Subscribed you to #{type} #{id}: #{resp}")
        end
      end

      def unsubscribe_to(response,id,type)
        subs = get_my_subscriptions(response,type)
        if subs.delete(id) == nil
          response.reply("#{id} wasn't in your #{type} list!")
        else
          resp = set_my_subscriptions(response,subs,type)
          response.reply("Unsubscribed you from #{type} #{id}: #{resp}")
        end
      end

    end

    Lita.register_handler(Cricket)
  end
end
