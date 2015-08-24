## Sensu-Plugins-http

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-http.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-http)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-http.svg)](http://badge.fury.io/rb/sensu-plugins-http)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-http/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-http)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-http/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-http)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-http.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-http)

## Functionality

## Files
 * bin/check-http-json.rb
 * bin/check-http.rb
 * bin/check-https-cert.rb
 * bin/check-last-modified.rb
 * bin/metrics-curl.rb
 * bin/metrics-http-json-deep.rb
 * bin/check-head-redirect.rb
 * bin/check-http-cors.rb

## Usage

check-head-redirect.rb and check-last-modified.rb can be used in conjunction with AWS to pull configuration from a specific bucket and file.

This is helpful if you do not want to configure connection information as an argument to the sensu checks. If a bucket and key are specified that the environment the sensu check executes in has access to, or you provide an AWS key and token, the checks will pull the specified JSON file from S3 and merge the JSON config in to the current check configuration.

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)

## Notes
