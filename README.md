## sensu-plugins-http

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-http.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-http)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-http.svg)](http://badge.fury.io/rb/sensu-plugins-http)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-http/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-http)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-http/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-http)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-http.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-http)

## Functionality

`sensu-plugins-http` allows you to check for HTTP codes, redirects, last modified times, JSON content. Furthermore you can collect metrics about JSON responses and details about the transfer (via `curl`).

### check-http-json.rb

Takes either a URL or a combination of host/path/query/port/ssl, and checks for valid JSON output in the response. This check will always check for HTTP status and JSON validity in addition to options you specify.

**parameters:**

- `-a PASSWORD, --password PASSWORD`: The password to use for authentication (default: None)
- `-b BODY`: The body sent with the request (default: None)
- `-C FILE, --cacert FILE`: The certificate authority (CA) certificate file your certificate is signed with - in case it is not in the default certificate store (default: None)
- `-c FILE, --cert FILE`: The TLS client-side certificate to be used in combination with your certificate key (default: None)
- `-h HEADER, --header HEADER`: One or more headers sent with the request (default: None)
- `-h HOST`: The host to connect to (default: None)
- `-K KEY, --key KEY`: The key to be used for a key-value lookup in the received JSON (default: None)
- `-k true|false`: Disable TLS certificate chain verification (default: `false`)
- `-m METHOD`: The method to use for the request, e.g. `GET`, `POST` (default: TODO)
- `-p PATH`: The path on the host to access (default: None)
- `-P PORT`: The port to connect to (default: None)
- `-q QUERY`: The query to run (default: None)
- `-s true|false`: Use an encrypted connection (default: `false`)
- `-t SECONDS`: The timeout used for the connection, in seconds (default: `15`)
- `-u URL`: The URL to connect to (default: None)
- `-U USERNAME, --username USERNAME`: The username to use for authentication (default: None)
- `-v VALUE, --value VALUE`: Check whether the value retrieved via -K is matches this value (default: None)
- `-w true|false, --whole-response true|false` (default: `false`)
- `--cert-key FILE`: The TLS certificate key to be used in combination with your client-side certificate (default: None)
- `--value-greater-than VALUE`: Check whether the value retrieved via -K is larger than this value (default: None)
- `--value-less-than VALUE`: Check whether the value retrieved via -K is smaller than this value (default: None)

---

Items below this separator subject to rework (branch will be rebased before merging)

---

## Files
 * bin/check-http-json.rb
 * bin/check-http.rb
 * bin/check-https-cert.rb
 * bin/check-last-modified.rb
 * bin/metrics-curl.rb
 * bin/metrics-http-json.rb
 * bin/metrics-http-json-deep.rb
 * bin/check-head-redirect.rb
 * bin/check-http-cors.rb

## Usage

`check-head-redirect.rb` and `check-last-modified.rb` can be used in conjunction with AWS to pull configuration from a specific bucket and file.

This is helpful if you do not want to configure connection information as an argument to the sensu checks. If a bucket and key are specified that the environment the sensu check executes in has access to, or you provide an AWS key and token, the checks will pull the specified JSON file from S3 and merge the JSON config in to the current check configuration.

`check-https-cert.rb` can be used to test for valid and successfully expired certs, amongst other things.

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)

## Notes

### check-http.rb and check-https-cert.rb
This check is not really geared to check all of the complexities of ssl which is why there is a separate repo and set of checks for that: https://github.com/sensu-plugins/sensu-plugins-ssl. If you are trying to verify cert expiration you will notice that in some cases it does not do what you always expect it to do. For example it might appear that when using using `-k` option you see different expiration times. This is due to the fact that when using `-k` it does not check expiration of all of the certs in the chain. Rather than duplicate this behavior in this check use the other repo where we handle those more complicated ssl checks better. For more information see: https://github.com/sensu-plugins/sensu-plugins-http/issues/67
