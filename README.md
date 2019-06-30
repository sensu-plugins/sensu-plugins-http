## Sensu-Plugins-http

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-http.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-http)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-http.svg)](http://badge.fury.io/rb/sensu-plugins-http)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-http.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-http)
[![Sensu Bonsai Asset](https://img.shields.io/badge/Bonsai-Download%20Me-brightgreen.svg?colorB=89C967&logo=sensu)](https://bonsai.sensu.io/assets/sensu-plugins/sensu-plugins-http)

## Sensu Asset  
  The Sensu assets packaged from this repository are built against the Sensu ruby runtime environment. When using these assets as part of a Sensu Go resource (check, mutator or handler), make sure you include the corresponding Sensu ruby runtime asset in the list of assets needed by the resource.  The current ruby-runtime assets can be found [here](https://bonsai.sensu.io/assets/sensu/sensu-ruby-runtime) in the [Bonsai Asset Index](bonsai.sensu.io).


## Functionality

## Files
 * bin/check-http-json.rb
 * bin/check-http.rb
 * bin/check-https-cert.rb
 * bin/check-last-modified.rb
 * bin/metrics-curl.rb
 * bin/metrics-libcurl.rb
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
### check-curl.rb and check-libcurl.rb
These metrics checks output equivalent metrics in graphite plaintext format. 
check-curl.rb operates by calling the curl executable with arbitrary arguments
```
metrics-curl.rb --help
Usage: metrics-curl.rb (options)
    -a, --curl_args "CURL ARGS"      Additional arguments to pass to curl
    -s, --scheme SCHEME              Metric naming scheme, text to prepend to metric (required)
    -u, --url URL                    valid cUrl url to connect

```

check-curllub.rb operators by calling into the libcurl library with arbitrary arguments.
```
metrics-libcurl.rb --help
Usage: metrics-libcurl.rb (options)
    -d, --debug                      Include debug output, should not use in production.
    -H, --headers  JSON              HTTP Request Headers as key/value JSON string
    -P, --params  JSON               HTTP Request Parameters as key/value JSON string
    -w, --warn_redirect              return warning status (1) if http response redirect status encountered (3xx)
    -c, --critical_http_error        return critical status (2) if http response error status encountered (>= 400)
    -o, --options  JSON              Libcurl Options as a key/value JSON string
    -s, --scheme SCHEME              Metric naming scheme, text to prepend to metric
    -u, --url URL                    valid cUrl url to connect (default: http://127.0.0.1:80/)
    -h, --help                       Show this message
Detailed Info:
  This wrapper makes use of libcurl directly instead of the curl executable by way of the Typhoeus RubyGem.
  You can provide additional libcurl options via the commandline using the --options argument.

Options Examples:
  Follow Redirects: --options '{"followlocation": true}'
  Use Proxy: --options '{proxy: "http://proxyurl.com", proxyuserpwd: "user:password"}'
  Disable TLS Verification: '{"ssl_verifypeer": false}'

References:
  Typhoeus Docs: https://www.rubydoc.info/gems/typhoeus/1.3.1
  Libcurl Options: https://curl.haxx.se/libcurl/c/curl_easy_setopt.html
```

### check-http.rb and check-https-cert.rb
This check is not really geared to check all of the complexities of ssl which is why there is a separate repo and set of checks for that: https://github.com/sensu-plugins/sensu-plugins-ssl. If you are trying to verify cert expiration you will notice that in some cases it does not do what you always expect it to do. For example it might appear that when using using `-k` option you see different expiration times. This is due to the fact that when using `-k` it does not check expiration of all of the certs in the chain. Rather than duplicate this behavior in this check use the other repo where we handle those more complicated ssl checks better. For more information see: https://github.com/sensu-plugins/sensu-plugins-http/issues/67
