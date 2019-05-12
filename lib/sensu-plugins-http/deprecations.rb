# frozen_string_literal: true

module SensuPluginsHttp
  module Deprecations
    class Messages
      def redirect_ok
        <<~STRING
          config[:redirectok] has been deprecated in favor of simply checking the specified
          desired response code vs what was returned. Given that you specify a 3XX response
          you can safely remove this option without further change. If you do not you will
          likely want something along the lines of "--response-code='^30([1-2])$'".
        STRING
      end
    end
  end
end
