#!/usr/bin/env ruby
#
#   check-http-json
#
# DESCRIPTION:
#   Takes either a URL or a combination of host/path/query/port/ssl, and checks
#   for valid JSON output in the response. Can also optionally validate simple
#   string key/value pairs.
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
#   #YELLOW
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
  option :header, short: '-H HEADER', long: '--header HEADER'
  option :ssl, short: '-s', boolean: true, default: false
  option :insecure, short: '-k', boolean: true, default: false
  option :user, short: '-U', long: '--username USER'
  option :password, short: '-a', long: '--password PASS'
  option :cert, short: '-c FILE'
  option :cacert, short: '-C FILE'
  option :timeout, short: '-t SECS', proc: proc(&:to_i), default: 15
  option :key, short: '-K KEY', long: '--key KEY'
  option :value, short: '-v VALUE', long: '--value VALUE'

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
    rescue => e
      critical "Connection error: #{e.message}"
    end
  end

  def json_valid?(str)
    JSON.parse(str)
    return true
  rescue JSON::ParserError
    return false
  end

  def acquire_resource
    http = Net::HTTP.new(config[:host], config[:port])

    if config[:ssl]
      http.use_ssl = true
      if config[:cert]
        cert_data = File.read(config[:cert])
        http.cert = OpenSSL::X509::Certificate.new(cert_data)
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

    critical res.code unless res.code =~ /^2/
    critical 'invalid JSON from request' unless json_valid?(res.body)
    ok 'valid JSON returned' if config[:key].nil? && config[:value].nil?

    json = JSON.parse(res.body)

    begin
      keys = config[:key].scan(/(?:\\\.|[^.])+/).map { |key| key.gsub(/\\./, '.') }

      leaf = keys.reduce(json) do |tree, key|
        raise "could not find key: #{config[:key]}" unless tree.key?(key)
        tree[key]
      end

      raise "unexpected value for key: '#{config[:value]}' != '#{leaf}'" unless leaf.to_s == config[:value].to_s

      ok "key has expected value: '#{config[:key]}' = '#{config[:value]}'"
    rescue => e
      critical "key check failed: #{e}"
    end
  end
end
