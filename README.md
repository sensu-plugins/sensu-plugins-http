## Sensu-Plugins-http

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-http.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-http)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-http.svg)](http://badge.fury.io/rb/sensu-plugins-http)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-http/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-http)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-http/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-http)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-http.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-http)

## Functionality

## Files
 * bin/check-http-json
 * bin/check-http
 * bin/check-https-cert
 * bin/metrics-curl

## Usage

## Installation

Add the public key (if you haven’t already) as a trusted certificate

```
gem cert --add <(curl -Ls https://raw.githubusercontent.com/sensu-plugins/sensu-plugins.github.io/master/certs/sensu-plugins.pem)
gem install sensu-plugins-http -P MediumSecurity
```

You can also download the key from /certs/ within each repository.

#### Rubygems

`gem install sensu-plugins-http`

#### Bundler

Add *sensu-plugins-disk-checks* to your Gemfile and run `bundle install` or `bundle update`

#### Chef

Using the Sensu **sensu_gem** LWRP
```
sensu_gem 'sensu-plugins-http' do
  options('--prerelease')
  version '0.0.1'
end
```

Using the Chef **gem_package** resource
```
gem_package 'sensu-plugins-http' do
  options('--prerelease')
  version '0.0.1'
end
```

## Notes
