#! /usr/bin/env ruby
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
#   Check response code - expect a 301 response
#   check-http.rb -u https://my.site.com/redirect --response-code 301 -r
#
#   Use a proxy to check a URL
#   check-http.rb -u https://www.google.com --proxy-url http://my.proxy.com:3128
#
# NOTES:
#
# LICENSE:
#   Copyright 2011 Sonian, Inc <chefs@sonian.net>
#   Updated by Lewis Preson 2012 to accept basic auth credentials
#   Updated by SweetSpot 2012 to require specified redirect
#   Updated by Chris Armstrong 2013 to accept multiple headers
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'net/http'
require 'net/https'

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
         short: '-m GET|POST',
         long: '--method GET|POST',
         description: 'Specify a GET or POST operation; defaults to GET',
         in: %w(GET POST),
         default: 'GET'

  option :header,
         short: '-H HEADER',
         long: '--header HEADER',
         description: 'Send one or more comma-separated headers with the request'

  option :body,
         short: '-b BODY',
         long: '--body BODY',
         description: 'Send a body string with the request'

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
         description: 'Query for a specific pattern'

  option :timeout,
         short: '-t SECS',
         long: '--timeout SECS',
         proc: proc(&:to_i),
         description: 'Set the timeout',
         default: 15

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

  option :response_code,
         long: '--response-code CODE',
         description: 'Check for a specific response code'

  option :proxy_url,
         long: '--proxy-url PROXY_URL',
         description: 'Use a proxy server to connect'

  option :no_proxy,
         long: '--noproxy',
         boolean: true,
         description: 'Do not use proxy server even from environment http_proxy setting',
         default: false

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

    begin
      Timeout.timeout(config[:timeout]) do
        acquire_resource
      end
    rescue Timeout::Error
      critical 'Request timed out'
    rescue => e
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
      http = Net::HTTP.new(config[:host], config[:port], proxy_uri.host, proxy_uri.port)
    else
      http = Net::HTTP.new(config[:host], config[:port])
    end
    http.read_timeout = config[:timeout]
    http.open_timeout = config[:timeout]
    http.ssl_timeout = config[:timeout]

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
          when 'POST'
            Net::HTTP::Post.new(config[:request_uri], 'User-Agent' => config[:ua])
          end

    if !config[:user].nil? && !config[:password].nil?
      req.basic_auth config[:user], config[:password]
    end
    if config[:header]
      config[:header].split(',').each do |header|
        h, v = header.split(':', 2)
        req[h.strip] = v.strip
      end
    end
    req.body = config[:body] if config[:body]

    res = http.request(req)

    body = if config[:whole_response]
             "\n" + res.body
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

    unless warn_cert_expire.nil?
      warning "Certificate will expire #{warn_cert_expire}"
    end

    size = res.body.nil? ? '0' : res.body.size

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
      else
        ok("#{res.code}, #{size} bytes" + body) unless config[:response_code]
      end
    when /^3/
      if config[:redirectok] || config[:redirectto]
        if config[:redirectok]
          # #YELLOW
          ok("#{res.code}, #{size} bytes" + body) unless config[:response_code] # rubocop:disable BlockNesting
        elsif config[:redirectto]
          # #YELLOW
          if config[:redirectto] == res['Location'] # rubocop:disable BlockNesting
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

    if config[:response_code]
      if config[:response_code] == res.code
        ok "#{res.code}, #{size} bytes" + body
      else
        critical res.code + body
      end
    end
  end
end
