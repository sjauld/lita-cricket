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
          'cricket -f' => 'Add a favourite team!'
        }
      )

      def refresh_user(response)
        my_favourites = redis.get(response.user.id)
        if my_favourites.nil?
          redis.set(response.user.id,[].to_json)
          response.reply('I can give you live cricket updates! Type `help cricket` for more information.')
        elsif
          update_favourites(response.user)
        end
      end

      def scores(response)
        response.reply('some_information_from_the_api')
      end

      def subscribe(response)
      end

      def unsubscribe(response)
      end

      def list(response)
        resp = HTTParty.get(@@ENDPOINT)
        #TODO: parse this list and keep going!!!
      end

      def favourite(response)
      end

      def update_favourites(response)
      end

    end

    Lita.register_handler(Cricket)
  end
end
