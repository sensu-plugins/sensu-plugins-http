[![Sensu Bonsai Asset](https://img.shields.io/badge/Bonsai-Download%20Me-brightgreen.svg?colorB=89C967&logo=sensu)](https://bonsai.sensu.io/assets/sensu-plugins/sensu-plugins-http)
[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-http.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-http)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-http.svg)](http://badge.fury.io/rb/sensu-plugins-http)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-http.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-http)

## Sensu HTTP Plugin

- [Overview](#overview)
- [Usage examples](#usage-examples)
- [Configuration](#configuration)
  - [Sensu Go](#sensu-go)
    - [Asset manifest](#asset-manifest)
    - [Check manifest](#check-manifest)
  - [Sensu Core](#sensu-core)
    - [Check definition](#check-definition)
- [Functionality](#functionality)
- [Additional information](#additional-information)
- [Installation](#installation)

### Overview 

This plugin provides native HTTP instrumentation for monitoring and metrics collection, including: response code, JSON response, HTTP last modified, SSL expiry, and metrics via `curl`.

#### Files
 * bin/check-http-json.rb
 * bin/check-http.rb
 * bin/check-https-cert.rb
 * bin/check-last-modified.rb
 * bin/metrics-curl.rb
 * bin/metrics-http-json.rb
 * bin/metrics-http-json-deep.rb
 * bin/check-head-redirect.rb
 * bin/check-http-cors.rb

## Usage examples

**check-http.rb**
```
Usage: check-http.rb (options)
        --aws-v4                     Sign http request with AWS v4 signature
        --aws-v4-region REGION       Region to use for AWS v4 signing.  Defaults to AWS_REGION or AWS_DEFAULT_REGION
        --aws-v4-service SERVICE     Service name to use when building the v4 signature
    -d, --body BODY                  Send a data body string with the request
    -C, --cacert FILE                A CA Cert to use
    -c, --cert FILE                  Cert to use
        --dns-timeout SECS           Number of seconds to allow for DNS resolution. Accepts decimal number.
    -e, --expiry EXPIRY              Warn EXPIRE days before cert expires
    -H, --header HEADER              Send one or more comma-separated headers with the request
    -h, --hostname HOSTNAME          A HOSTNAME to connect to
    -k                               Enabling insecure connections
    -m, --method GET|POST|PUT        Specify a GET, POST, or PUT operation; defaults to GET (included in ['GET', 'POST', 'PUT'])
    -g, --min-bytes BYTES            Check the response contains at least BYTES bytes
    -n, --negquery PAT               Query for a specific pattern that must be absent
        --noproxy                    Do not use proxy server even from environment http_proxy setting
        --open-timeout SECS          Number of seconds to wait for the connection to open
    -a, --password PASS              A password to use for the username
    -q, --query PAT                  Query for a specific pattern that must exist
    -P, --port PORT                  Select another port
        --proxy-url PROXY_URL        Use a proxy server to connect
        --read-timeout SECS          Number of seconds to wait for one block to be read
    -r                               Check if a redirect is ok
    -R, --redirect-to URL            Redirect to another page
    -p, --request-uri PATH           Specify a uri path
    -B, --require-bytes BYTES        Check the response contains exactly BYTES bytes
    -b, --response-bytes BYTES       Print BYTES of the output
        --response-code REGEX        Critical if HTTP response code does not match REGEX
    -S, --checksum CHECKSUM          SHA-256 checksum
    -s                               Enabling SSL connections
    -t, --timeout SECS               Set the total execution timeout in seconds
    -x, --user-agent USER-AGENT      Specify a USER-AGENT
    -u, --url URL                    A URL to connect to
    -U, --username USER              A username to connect as
    -w, --whole-response             Print whole output when check fails

```

**metrics-curl.rb**
```
Usage: metrics-curl.rb (options)
    -a, --curl_args "CURL ARGS"      Additional arguments to pass to curl
    -s, --scheme SCHEME              Metric naming scheme, text to prepend to metric (required)
    -u, --url URL                    valid cUrl url to connect

```

### Configuration
#### Sensu Go
##### Asset registration

Assets are the best way to make use of this handler. If you're not using an asset, please consider doing so! If you're using sensuctl 5.13 or later, you can use the following command to add the asset: 

`sensuctl asset add sensu-plugins/sensu-plugins-http`

If you're using an earlier version of sensuctl, you can download the asset definition from [this project's Bonsai Asset Index page](https://bonsai.sensu.io/assets/sensu-plugins/sensu-plugins-http).

##### Asset manifest

```yaml
---
type: Asset
api_version: core/v2
metadata:
  name: sensu-plugins-http
spec:
  url: https://assets.bonsai.sensu.io/30d8361243af8c7806e2d6db4a6dc576dab02966/sensu-plugins-http_5.1.1_centos_linux_amd64.tar.gz
  sha512: 642643d00c6af177d2e159b9152c0a513c1b193622c1e6dc2735b7518ce57a1522186dcbf62d6cfbdf1c79c45215f1142d362276815c31aa6071d49735bf1d35
```

##### Check manifest

```yaml
---
type: CheckConfig
spec:
  command: "metrics-curl.rb -u https://google.com"
  handlers: []
  high_flap_threshold: 0
  interval: 10
  low_flap_threshold: 0
  publish: true
  runtime_assets:
  - sensu-plugins-http
  - sensu-ruby-runtime
  subscriptions:
  - linux
  output_metric_format: graphite_plaintext
  output_metric_handlers:
  - influx-db
```
#### Sensu Core
##### Check definition
```json
{
  "checks": {
    "check-http": {
    "command": "check-http.rb -u https://google.com",
    "subscribers": [
      "webservers"
    ],
    "interval": 60
    }
  }
}
```

### Additional information

`check-head-redirect.rb` and `check-last-modified.rb` can be used in conjunction with AWS to pull configuration from a specific bucket and file.

This is helpful if you do not want to configure connection information as an argument to the sensu checks. If a bucket and key are specified that the environment the sensu check executes in has access to, or you provide an AWS key and token, the checks will pull the specified JSON file from S3 and merge the JSON config in to the current check configuration.

`check-https-cert.rb` can be used to test for valid and successfully expired certs, amongst other things.

## Installation

### Sensu Go

See the instructions above for [asset registration](#asset-registration)

### Sensu Core
Install and setup plugins on [Sensu Core](https://docs.sensu.io/sensu-core/latest/installation/installing-plugins/)

## Notes

### check-http.rb and check-https-cert.rb
This check is not really geared to check all of the complexities of ssl which is why there is a separate repo and set of checks for that: https://github.com/sensu-plugins/sensu-plugins-ssl. If you are trying to verify cert expiration you will notice that in some cases it does not do what you always expect it to do. For example it might appear that when using using `-k` option you see different expiration times. This is due to the fact that when using `-k` it does not check expiration of all of the certs in the chain. Rather than duplicate this behavior in this check use the other repo where we handle those more complicated ssl checks better. For more information see: https://github.com/sensu-plugins/sensu-plugins-http/issues/67
