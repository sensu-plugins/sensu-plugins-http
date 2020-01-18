#!/usr/bin/env ruby
# frozen_string_literal: false

#
#   check-http
#
# DESCRIPTION:
#   Takes either a URL or a combination of host/path/port/ssl, and checks for
#   a 200 response (that matches a pattern, if given). Can use client certs.
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#   Basic HTTP check - expect a 200 response
#   check-http.rb -u http://my.site.com
#
#   Pattern check - expect a 200 response and the string 'OK' in the body
#   check-http.rb -u http://my.site.com/health -q 'OK'
#
#   Check if a response is greater than the specified minimum value
#   check-http.rb -u https://my.site.com/redirect --min-bytes 10
#
#   Check response code - expect a 301 response
#   check-http.rb -u https://my.site.com/redirect --response-code 301 -r
#
#   Use a proxy to check a URL
#   check-http.rb -u https://www.google.com --proxy-url http://my.proxy.com:3128
#
#   Use a proxy with username and password to check a URL
#   NOTE: Use 'check token substition' to avoid credentials leakage!
#   check-http.rb -u https://www.google.com --proxy-url http://a_user:a_pass@my.proxy.com:3128
#
#   Check something with needing to set multiple headers
#   check-http.rb -u https://www.google.com --header 'Origin: ma.local.box, SomeRandomHeader: foo'
#
#   Check something that requires a POST with json data
#   check-http.rb -u https://httpbin.org/post --method POST --header 'Content-type: application/json' --body '{"foo": "bar"}'
# NOTES:
#
# LICENSE:
#   Copyright 2011 Sonian, Inc <chefs@sonian.net>
#   Updated by Lewis Preson 2012 to accept basic auth credentials
#   Updated by SweetSpot 2012 to require specified redirect
#   Updated by Chris Armstrong 2013 to accept multiple headers
#   Updated by Mark Clarkson 2018 to accept proxy auth credentials
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugins-http'
require 'sensu-plugin/check/cli'
require 'net/http'
require 'net/https'
require 'digest'
require 'resolv-replace'

#
# Check HTTP
#
class CheckHttp < Sensu::Plugin::Check::CLI
  option :ua,
         short: '-x USER-AGENT',
         long: '--user-agent USER-AGENT',
         description: 'Specify a USER-AGENT',
         default: 'Sensu-HTTP-Check'

  option :url,
         short: '-u URL',
         long: '--url URL',
         description: 'A URL to connect to'

  option :host,
         short: '-h HOST',
         long: '--hostname HOSTNAME',
         description: 'A HOSTNAME to connect to'

  option :port,
         short: '-P PORT',
         long: '--port PORT',
         proc: proc(&:to_i),
         description: 'Select another port'

  option :request_uri,
         short: '-p PATH',
         long: '--request-uri PATH',
         description: 'Specify a uri path'

  option :method,
         short: '-m GET|HEAD|POST|PUT',
         long: '--method GET|HEAD|POST|PUT',
         description: 'Specify a GET, HEAD, POST, or PUT operation; defaults to GET',
         in: %w[GET HEAD POST PUT],
         default: 'GET'

  option :header,
         short: '-H HEADER',
         long: '--header HEADER',
         description: 'Send one or more comma-separated headers with the request'

  option :headerfile,
         long: '--headerfile FILE',
         description: 'Send headers with the request, read from FILE, separated by newline'

  option :body,
         short: '-d BODY',
         long: '--body BODY',
         description: 'Send a data body string with the request'

  option :ssl,
         short: '-s',
         boolean: true,
         description: 'Enabling SSL connections',
         default: false

  option :insecure,
         short: '-k',
         boolean: true,
         description: 'Enabling insecure connections',
         default: false

  option :user,
         short: '-U',
         long: '--username USER',
         description: 'A username to connect as'

  option :password,
         short: '-a',
         long: '--password PASS',
         description: 'A password to use for the username'

  option :cert,
         short: '-c FILE',
         long: '--cert FILE',
         description: 'Cert to use'

  option :cacert,
         short: '-C FILE',
         long: '--cacert FILE',
         description: 'A CA Cert to use'

  option :expiry,
         short: '-e EXPIRY',
         long: '--expiry EXPIRY',
         proc: proc(&:to_i),
         description: 'Warn EXPIRE days before cert expires'

  option :pattern,
         short: '-q PAT',
         long: '--query PAT',
         description: 'Query for a specific pattern that must exist'

  option :negpattern,
         short: '-n PAT',
         long: '--negquery PAT',
         description: 'Query for a specific pattern that must be absent'

  option :sha256checksum,
         short: '-S CHECKSUM',
         long: '--checksum CHECKSUM',
         description: 'SHA-256 checksum'

  option :timeout,
         short: '-t SECS',
         long: '--timeout SECS',
         proc: proc(&:to_i),
         description: 'Set the total execution timeout in seconds',
         default: 15

  option :open_timeout,
         long: '--open-timeout SECS',
         proc: proc(&:to_i),
         description: 'Number of seconds to wait for the connection to open',
         default: 15

  option :read_timeout,
         long: '--read-timeout SECS',
         proc: proc(&:to_i),
         description: 'Number of seconds to wait for one block to be read',
         default: 15

  option :dns_timeout,
         long: '--dns-timeout SECS',
         proc: proc(&:to_f),
         description: 'Number of seconds to allow for DNS resolution. Accepts decimal number.',
         default: 0.8

  option :redirectok,
         short: '-r',
         boolean: true,
         description: 'Check if a redirect is ok',
         default: false

  option :redirectto,
         short: '-R URL',
         long: '--redirect-to URL',
         description: 'Redirect to another page'

  option :whole_response,
         short: '-w',
         long: '--whole-response',
         boolean: true,
         default: false,
         description: 'Print whole output when check fails'

  option :response_bytes,
         short: '-b BYTES',
         long: '--response-bytes BYTES',
         description: 'Print BYTES of the output',
         proc: proc(&:to_i)

  option :require_bytes,
         short: '-B BYTES',
         long: '--require-bytes BYTES',
         description: 'Check the response contains exactly BYTES bytes',
         proc: proc(&:to_i)

  option :min_bytes,
         short: '-g BYTES',
         long: '--min-bytes BYTES',
         description: 'Check the response contains at least BYTES bytes',
         proc: proc(&:to_i)

  option :response_code,
         long: '--response-code REGEX',
         description: 'Critical if HTTP response code does not match REGEX'

  option :proxy_url,
         long: '--proxy-url PROXY_URL',
         description: 'Use a proxy server to connect'

  option :no_proxy,
         long: '--noproxy',
         boolean: true,
         description: 'Do not use proxy server even from environment http_proxy setting',
         default: false

  option :aws_v4,
         long: '--aws-v4',
         boolean: true,
         description: 'Sign http request with AWS v4 signature',
         default: false

  option :aws_v4_region,
         long: '--aws-v4-region REGION',
         description: 'Region to use for AWS v4 signing.  Defaults to AWS_REGION or AWS_DEFAULT_REGION'

  option :aws_v4_service,
         long: '--aws-v4-service SERVICE',
         description: 'Service name to use when building the v4 signature',
         default: 'execute-api'

  include SensuPluginsHttp::AwsV4

  def run
    if config[:url]
      uri = URI.parse(config[:url])
      config[:host] = uri.host
      config[:port] = uri.port
      config[:request_uri] = uri.request_uri
      config[:ssl] = uri.scheme == 'https'
    else
      # #YELLOW
      unless config[:host] && config[:request_uri]
        unknown 'No URL specified'
      end
      config[:port] ||= config[:ssl] ? 443 : 80
    end

    # Use Ruby DNS Resolver and set DNS resolution timeout to dns_timeout value
    hosts_resolver = Resolv::Hosts.new
    dns_resolver = Resolv::DNS.new
    dns_resolver.timeouts = config[:dns_timeout]
    Resolv::DefaultResolver.replace_resolvers([hosts_resolver, dns_resolver])

    begin
      Timeout.timeout(config[:timeout]) do
        acquire_resource
      end
    rescue Net::OpenTimeout
      critical 'Request timed out opening connection'
    rescue Net::ReadTimeout
      critical 'Request timed out reading data'
    rescue Timeout::Error
      critical 'Request timed out'
    rescue StandardError => e
      critical "Request error: #{e.message}"
    end
  end

  def acquire_resource
    http = nil

    if config[:no_proxy]
      http = Net::HTTP.new(config[:host], config[:port], nil, nil)
    elsif config[:proxy_url]
      proxy_uri = URI.parse(config[:proxy_url])
      if proxy_uri.host.nil?
        unknown 'Invalid proxy url specified'
      end
      http = if proxy_uri.user && proxy_uri.password
               Net::HTTP.new(config[:host], config[:port], proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.password)
             else
               Net::HTTP.new(config[:host], config[:port], proxy_uri.host, proxy_uri.port)
             end
    else
      http = Net::HTTP.new(config[:host], config[:port])
    end
    http.read_timeout = config[:read_timeout]
    http.open_timeout = config[:open_timeout]
    http.ssl_timeout = config[:timeout]
    http.continue_timeout = config[:timeout]
    http.keep_alive_timeout = config[:timeout]

    warn_cert_expire = nil
    if config[:ssl]
      http.use_ssl = true
      if config[:cert]
        cert_data = File.read(config[:cert])
        http.cert = OpenSSL::X509::Certificate.new(cert_data)
        http.key = OpenSSL::PKey::RSA.new(cert_data, nil)
      end
      http.ca_file = config[:cacert] if config[:cacert]
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if config[:insecure]

      unless config[:expiry].nil?
        expire_warn_date = Time.now + (config[:expiry] * 60 * 60 * 24)
        # We can't raise inside the callback, have to check when we finish.
        http.verify_callback = proc do |preverify_ok, ssl_context|
          if ssl_context.current_cert.not_after <= expire_warn_date
            warn_cert_expire = ssl_context.current_cert.not_after
          end

          preverify_ok
        end
      end
    end

    req = case config[:method]
          when 'GET'
            Net::HTTP::Get.new(config[:request_uri], 'User-Agent' => config[:ua])
          when 'HEAD'
            Net::HTTP::Head.new(config[:request_uri], 'User-Agent' => config[:ua])
          when 'POST'
            Net::HTTP::Post.new(config[:request_uri], 'User-Agent' => config[:ua])
          when 'PUT'
            Net::HTTP::Put.new(config[:request_uri], 'User-Agent' => config[:ua])
          end

    unless config[:user].nil? && config[:password].nil?
      req.basic_auth config[:user], config[:password]
    end
    if config[:header]
      config[:header].split(',').each do |header|
        h, v = header.split(':', 2)
        req[h.strip] = v.strip
      end
    end

    if config[:headerfile]
      File.readlines(config[:headerfile]).each do |line|
        h, v = line.split(':', 2)
        req[h.strip] = v.strip
      end
    end

    req.body = config[:body] if config[:body]

    req = apply_v4_signature(http, req, config) if config[:aws_v4]

    res = http.request(req)

    body = if config[:whole_response]
             "\n" + res.body.to_s
           else
             body = if config[:response_bytes] # rubocop:disable Lint/UselessAssignment
                      "\n" + res.body[0..config[:response_bytes]]
                    else
                      ''
                    end
           end

    if config[:require_bytes] && res.body.length != config[:require_bytes]
      critical "Response was #{res.body.length} bytes instead of #{config[:require_bytes]}" + body
    end

    if config[:min_bytes] && res.body.length < config[:min_bytes]
      critical "Response was #{res.body.length} bytes instead of the indicated minimum #{config[:min_bytes]}" + body
    end

    unless warn_cert_expire.nil?
      warning "Certificate will expire #{warn_cert_expire}"
    end

    size = res.body.nil? ? '0' : res.body.size

    handle_response(res, size, body)
  end

  def handle_response(res, size, body)
    case res.code
    when /^2/
      if config[:redirectto]
        critical "Expected redirect to #{config[:redirectto]} but got #{res.code}" + body
      elsif config[:pattern]
        if res.body =~ /#{config[:pattern]}/
          ok "#{res.code}, found /#{config[:pattern]}/ in #{size} bytes" + body
        else
          critical "#{res.code}, did not find /#{config[:pattern]}/ in #{size} bytes: #{res.body[0...200]}..."
        end
      elsif config[:negpattern]
        if res.body =~ /#{config[:negpattern]}/
          critical "#{res.code}, found /#{config[:negpattern]}/ in #{size} bytes: #{res.body[0...200]}..."
        else
          ok "#{res.code}, did not find /#{config[:negpattern]}/ in #{size} bytes" + body
        end
      elsif config[:sha256checksum]
        if Digest::SHA256.hexdigest(res.body).eql? config[:sha256checksum]
          ok "#{res.code}, checksum match #{config[:sha256checksum]} in #{size} bytes" + body
        else
          critical "#{res.code}, checksum did not match #{config[:sha256checksum]} in #{size} bytes: #{res.body[0...200]}..."
        end
      else
        ok("#{res.code}, #{size} bytes" + body) unless config[:response_code]
      end
    when /^3/
      if config[:redirectok] || config[:redirectto]
        if config[:redirectok]
          # #YELLOW
          ok("#{res.code}, #{size} bytes" + body) unless config[:response_code] # rubocop:disable Metrics/BlockNesting
        elsif config[:redirectto]
          # #YELLOW
          if config[:redirectto] == res['Location'] # rubocop:disable Metrics/BlockNesting
            ok "#{res.code} found redirect to #{res['Location']}" + body
          else
            critical "Expected redirect to #{config[:redirectto]} instead redirected to #{res['Location']}" + body
          end
        end
      else
        warning res.code + body
      end
    when /^4/, /^5/
      critical(res.code + body) unless config[:response_code]
    else
      warning(res.code + body) unless config[:response_code]
    end

    if config[:response_code] && res.code =~ /#{config[:response_code]}/
      ok "#{res.code}, #{size} bytes" + body

    else
      critical res.code + body
    end
  end
end
