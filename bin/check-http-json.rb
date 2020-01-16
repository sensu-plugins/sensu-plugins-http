#!/usr/bin/env ruby
# frozen_string_literal: false

#
#   check-http-json
#
# DESCRIPTION:
#   Takes either a URL or a combination of host/path/query/port/ssl, and checks
#   for valid JSON output in the response. Can also optionally validate simple
#   string key/value pairs, and optionally check if a specified value is within
#   bounds.
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: json
#
# USAGE:
#   Check that will verify http status and JSON validity
#      ./check-http-json.rb -u http://my.site.com/health.json
#
#   Check that will verify http status, JSON validity, and that page.totalElements value is
#   greater than 10
#      ./check-http-json.rb -u http://my.site.com/metric.json --key page.totalElements --value-greater-than 10
#
#   Check that will POST json
#      ./check-http-json.rb -u http://my.site.com/metric.json -m POST --header 'Content-type: application/json' --post-body '{"serverId": "myserver"}'
#
# NOTES:
#   Based on Check HTTP by Sonian Inc.
#
# LICENSE:
#   Copyright 2013 Matt Revell <nightowlmatt@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'json'
require 'net/http'
require 'net/https'

#
# Check JSON
#
class CheckJson < Sensu::Plugin::Check::CLI
  option :url, short: '-u URL'
  option :host, short: '-h HOST'
  option :path, short: '-p PATH'
  option :query, short: '-q QUERY'
  option :port, short: '-P PORT', proc: proc(&:to_i)
  option :method, short: '-m GET|POST'
  option :postbody, short: '-b /file/with/post/body'
  option :post_body, long: '--post-body VALUE'
  option :header, short: '-H HEADER', long: '--header HEADER'
  option :ssl, short: '-s', boolean: true, default: false
  option :insecure, short: '-k', boolean: true, default: false
  option :user, short: '-U', long: '--username USER'
  option :password, short: '-a', long: '--password PASS'
  option :cert, short: '-c FILE', long: '--cert FILE'
  option :certkey, long: '--cert-key FILE'
  option :cacert, short: '-C FILE', long: '--cacert FILE'
  option :timeout, short: '-t SECS', proc: proc(&:to_i), default: 15
  option :key, short: '-K KEY', long: '--key KEY'
  option :value, short: '-v VALUE', long: '--value VALUE'
  option :valueGt, long: '--value-greater-than VALUE'
  option :valueLt, long: '--value-less-than VALUE'
  option :whole_response, short: '-w', long: '--whole-response', boolean: true, default: false
  option :dump_json, short: '-d', long: '--dump-json', boolean: true, default: false
  option :pretty, long: '--pretty', boolean: true, default: false

  option :response_code,
         long: '--response-code REGEX',
         description: 'Critical if HTTP response code does not match REGEX',
         default: '^2([0-9]{2})$'

  def run
    if config[:url]
      uri = URI.parse(config[:url])
      config[:host] = uri.host
      config[:path] = uri.path
      config[:query] = uri.query
      config[:port] = uri.port
      config[:ssl] = uri.scheme == 'https'
    else
      # #YELLOW
      unless config[:host] && config[:path]
        unknown 'No URL specified'
      end
      config[:port] ||= config[:ssl] ? 443 : 80
    end

    begin
      Timeout.timeout(config[:timeout]) do
        acquire_resource
      end
    rescue Timeout::Error
      critical 'Connection timed out'
    rescue StandardError => e
      critical "Connection error: #{e.message}"
    end
  end

  def deep_value(data, desired_key, parent = '')
    case data
    when Array
      data.each_with_index do |value, index|
        arr_key = parent + '[' + index.to_s + ']'

        if arr_key == desired_key
          return value.nil? ? 'null' : value
        end

        if desired_key.include? arr_key
          search = deep_value(value, desired_key, arr_key)

          return search unless search.nil?
        end
      end
    when Hash
      data.each do |key, value|
        key_prefix = parent.empty? ? '' : '.'
        hash_key = parent + key_prefix + key

        if hash_key == desired_key
          return value.nil? ? 'null' : value
        end

        if desired_key.include?(hash_key + '.') || desired_key.include?(hash_key + '[')
          search = deep_value(value, desired_key, hash_key)

          return search unless search.nil?
        end
      end
    end
  end

  def json_valid?(str)
    ::JSON.parse(str)
    true
  rescue ::JSON::ParserError
    false
  end

  def acquire_resource
    http = Net::HTTP.new(config[:host], config[:port])

    if config[:ssl]
      http.use_ssl = true
      if config[:cert]
        cert_data = File.read(config[:cert])
        http.cert = OpenSSL::X509::Certificate.new(cert_data)
        if config[:certkey]
          cert_data = File.read(config[:certkey])
        end
        http.key = OpenSSL::PKey::RSA.new(cert_data, nil)
      end
      http.ca_file = config[:cacert] if config[:cacert]
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if config[:insecure]
    end

    req = if config[:method] == 'POST'
            Net::HTTP::Post.new([config[:path], config[:query]].compact.join('?'))
          else
            Net::HTTP::Get.new([config[:path], config[:query]].compact.join('?'))
          end
    if config[:postbody]
      post_body = IO.readlines(config[:postbody])
      req.body = post_body.join
    end
    if config[:post_body]
      req.body = config[:post_body]
    end
    unless config[:user].nil? && config[:password].nil?
      req.basic_auth config[:user], config[:password]
    end
    if config[:header]
      config[:header].split(',').each do |header|
        h, v = header.split(':', 2)
        req[h] = v.strip
      end
    end
    res = http.request(req)

    if res.code !~ /#{config[:response_code]}/
      critical "http code: #{res.code}: body: #{res.body}" if config[:whole_response]
      critical res.code
    end
    critical 'invalid JSON from request' unless json_valid?(res.body)
    ok 'valid JSON returned' if config[:key].nil? && config[:value].nil?

    json = ::JSON.parse(res.body)

    begin
      leaf = deep_value(json, config[:key])

      raise "could not find key: #{config[:key]}" if leaf.nil?

      message = "key has expected value: '#{config[:key]}' "
      if config[:value]
        raise "unexpected value for key: '#{leaf}' != '#{config[:value]}'" unless leaf.to_s == config[:value].to_s

        message += "equals '#{config[:value]}'"
      end
      if config[:valueGt]
        raise "unexpected value for key: '#{leaf}' not > '#{config[:valueGt]}'" unless leaf.to_f > config[:valueGt].to_f

        message += "greater than '#{config[:valueGt]}'"
      end
      if config[:valueLt]
        raise "unexpected value for key: '#{leaf}' not < '#{config[:valueLt]}'" unless leaf.to_f < config[:valueLt].to_f

        message += "less than '#{config[:valueLt]}'"
      end

      ok message
    rescue StandardError => e
      if config[:dump_json]
        json_response = config[:pretty] ? ::JSON.pretty_generate(json) : json
        message = "key check failed: #{e}. Response: #{json_response}"
      else
        message = "key check failed: #{e}"
      end
      critical message
    end
  end
end
