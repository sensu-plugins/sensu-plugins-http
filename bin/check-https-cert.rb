#!/usr/bin/env ruby
# frozen_string_literal: false

#
#   check-https-cert
#
# DESCRIPTION:
#    Checks the expiration date of a URL's TLS/SSL Certificate
#    and notifies if it is before the expiry parameter. Throws
#    a critical if the date is at or past the expiry date.
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: net-https
#
# USAGE:
#   Check that will warn 1 week prior and critical 3 days prior
#      ./check-https-cert.rb -u https://my.site.com -w 7 -c 3
#
#   Check an insecure certificate that will warn 1 week prior and critical 3 days prior
#      ./check-https-cert.rb -u https://my.site.com -k -w 7 -c 3
#
#   Check that a certificate has successfully expired
#      ./check-https-cert.rb -u https://my.site.com -k -e
#
# NOTES:
#
# LICENSE:
#   Copyright 2014 Rhommel Lamas <roml@rhommell.com>
#   Updated 2017 Phil Porada <philporada@gmail.com>
#     - Provide more clear usage documentation and messages
#     - Added check for successfully expired certificate
#     - Added long flags
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'net/https'

#
# Check HTTP
#
class CheckHttpCert < Sensu::Plugin::Check::CLI
  option :url,
         short: '-u URL',
         long: '--url URL',
         proc: proc(&:to_s),
         description: 'The URL to connect to'

  option :warning,
         short: '-w',
         long: '--warning DAYS',
         proc: proc(&:to_i),
         default: 50,
         description: 'Warn EXPIRE days before cert expires'

  option :critical,
         short: '-c',
         long: '--critical DAYS',
         proc: proc(&:to_i),
         default: 25,
         description: 'Critical EXPIRE days before cert expires'

  option :expired,
         short: '-e',
         long: '--expired',
         boolean: true,
         description: 'Expect certificate to be expired',
         default: false

  option :insecure,
         short: '-k',
         long: '--insecure',
         boolean: true,
         description: 'Enabling insecure connections',
         default: false

  def run
    uri = URI.parse(config[:url])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = if config[:insecure]
                         OpenSSL::SSL::VERIFY_NONE
                       else
                         OpenSSL::SSL::VERIFY_PEER
                       end

    http.start do |h|
      @cert = h.peer_cert
    end
    days_until = ((@cert.not_after - Time.now) / (60 * 60 * 24)).to_i

    if config[:expired]
      if days_until >= 0
        critical "TLS/SSL certificate expires on #{@cert.not_after} - #{days_until} days left."
      else
        ok "TLS/SSL certificate expired #{days_until.abs} days ago."
      end
    end

    unless config[:expired]
      if days_until <= 0
        critical "TLS/SSL certificate expired #{days_until.abs} days ago."
      elsif days_until < config[:critical].to_i
        critical "TLS/SSL certificate expires on #{@cert.not_after} - #{days_until} days left."
      elsif days_until < config[:warning].to_i
        warning "TLS/SSL certificate expires on #{@cert.not_after} - #{days_until} days left."
      else
        ok "TLS/SSL certificate expires on #{@cert.not_after} - #{days_until} days left."
      end
    end
  rescue StandardError
    critical "Could not connect to #{config[:url]}"
  end
end
