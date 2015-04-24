require 'json'

# encoding: utf-8
module SensuPluginsHttp
  # This defines the version of the gem
  module Version
    MAJOR = 0
    MINOR = 0
    PATCH = 2

    VER_STRING = [MAJOR, MINOR, PATCH].compact.join('.')

    NAME   = 'sensu-plugins-http'
    BANNER = "#{NAME} v%s"

    module_function

    def version
      format(BANNER, VER_STRING)
    end

    def json_version
      {
        'version' => VER_STRING
      }.to_json
    end
  end
end
