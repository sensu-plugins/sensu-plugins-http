# frozen_string_literal: true

module SensuPluginsHttp
  module AwsV4
    # Returns a modified request object with AWS v4 signature headers
    # and authentication options (if any)
    #
    # @param [Net::HTTP] http
    #   The http object used to execute the request.  Used to build uri
    # @param [Net::HTTPGenericRequest] req
    #   The http request.  Used to populate headers, path, method, and body
    # @param [Hash] options Details about how to configure the request
    # @option options [String] :aws_v4_service
    #   AWS service to use in signature.  Defaults to 'execute-api'
    # @option options [String] :aws_v4_region
    #   AWS region to use in signature.  Defaults to
    #   ENV['AWS_REGION'] or ENV['AWS_DEFAULT_REGION']
    def apply_v4_signature(http, req, options = {})
      require 'aws-sdk'

      fake_seahorse = Struct.new(:endpoint, :body, :headers, :http_method)
      headers = {}
      req.each_name { |name| headers[name] = req[name] }
      protocol = http.use_ssl? ? 'https' : 'http'
      uri = URI.parse("#{protocol}://#{http.address}:#{http.port}#{req.path}")
      fake_req = fake_seahorse.new(uri, req.body || '',
                                   headers, req.method)

      credentials = Aws::CredentialProviderChain.new.resolve
      service = options[:aws_v4_service] || 'execute-api'
      region = options[:aws_v4_region] || ENV['AWS_REGION'] || ENV['AWS_DEFAULT_REGION']
      signer = Aws::Signers::V4.new(credentials, service, region)

      signed_req = signer.sign(fake_req)
      signed_req.headers.each { |key, value| req[key] = value }

      req
    end
  end
end
