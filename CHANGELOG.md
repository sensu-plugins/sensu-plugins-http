# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed [here](https://github.com/sensu-plugins/community/blob/master/HOW_WE_CHANGELOG.md)

## [Unreleased]


## [2.9.0] - 2018-05-03
### Added
- `check-http-json.rb`: add option `--post-body` to include a post body (@andy-s-clark)

## [2.8.4] - 2018-03-27
### Security
- updated yard dependency to `~> 0.9.11` per: https://nvd.nist.gov/vuln/detail/CVE-2017-17042 (@majormoses)

## [2.8.3] - 2018-03-14
### Fixed
- `metrics-curl.rb`: fix shell quoting problem at execution and parse correctly curl metrics on non-C locale. (@multani)

## [2.8.2] - 2018-03-13
### Fixed
- most of the scripts failed when `# frozen_string_literal: true` was set because `mixlib-cli` does not support this. This reverts the old behavior in the checks but leaves libs which were unaffected alone (@majormoses)

### Added
- integration testing skel and added some tests (@majormoses)

## [2.8.1] - 2018-03-07
### Security
- updated rubocop dependency to `~> 0.51.0` per: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-8418. (@majormoses)

### Changed
- appeased the cops, updated cop config, and created TODOs for refactoring (@majormoses)

## [2.8.0] - 2018-02-17
### Added
- Add new options `--dump-json` to dump json response on failure when enable. default: false (@jplindquist)
- Add new `--pretty` option for pretty format json response when `--dump-json` is enabled. default: false (@jplindquist)

## [2.7.0] - 2018-02-15
### Added
- `check-http`: Added ability to use username and password in proxy url (@mclarkson)

### Changed
- updated changelog location guidelines (@majormoses)

## [2.6.0] - 2017-07-31
### Added
- ruby 2.4 testing (@majormoses)

### Fixed
- spelling in PR template (@majormoses)
- use rest-client 2.0 to fix issue with OpenSSL 1.1.0 (@ushis)

## [2.5.0] - 2017-07-06
### Added
- `check-http`: Added ability to sign requests with AWS V4 authentication (@ajmath)

## [2.4.0] - 2017-06-19
### Added
- Initial set of tests for `check-https-cert.rb` (@pgporada)
- `check-https-cert.rb`: Allow checking for a successfully expired certificate (@pgporada)

## [2.3.0] - 2017-06-01
### Added
- check-http.rb: support PUT requests (@majormoses)
- check-http.rb: added examples per GH issues (@majormoses)

## [2.2.0] - 2017-05-31
### Added
- `check-http-json`: add --value-greater-than and --value-less-than options (@dave-handy)

## [2.1.0]
### Fixed
- `check-http-json`: fix error when check fails and --whole-response is enabled (@ushis)

### Added
- `check-http`: add checksum check
- documentation on ssl issues (@majormoses @pgporada)

## [2.0.2] - 2017-03-13
### Fixed
- `metrics-http-json-deep`: fix Regexp error (@nevins-b)

## [2.0.1] - 2017-02-21
### Fixed
- `check-http-json`: fix incorrect "key not found" error when key value is null (@marktheunissen)

## [2.0.0] - 2017-02-20
### Breaking Changes
- Support for Ruby < 2.1 removed. Ruby 2.0 and older are EOL.
- The `-b` option in `check-http` to send a data body with the request has been changed to `-d` to
  avoid conflicting with the `-b` option to print the bytes of the response.

### Changed
- Revert rest-client to 1.8 as 2.0 requires ruby >= 2.0 (@sstarcher)
- `check-http`: change conflicting body short argument letter to `-d` for data (@rmkbow)

### Fixed
- `metrics-http-json`: fix behavior when a root object key is not specified (@mrooney)
- Fix CI tests (@RoboticCheese)

### Added
- `check-http-json`: add an option to return response body (@obazoud)
- `check-http-json`: support nested hash/array paths in key (@parisholley)

### Removed
- Support for Ruby < 2.1 (@eheydrick)

## [1.0.0] - 2016-07-27
### Fixed
- Don't send basic auth when no password is supplied
- Add default thresholds to check-https-cert.rb
- check-http: fix default port selection for https

### Added
- Add `rest-client` dependency for `metrics-http-json`
- Add `check-head-redirect` that checks that redirection links can be followed in a set number of requests
- Add `check-http-cors` that checks CORS headers
- check-http-json: add `cert-key` parameter to allow specifying a separate cert file
- Add `--negquery` to `check-http.rb` for query text that should not exist

### Removed
- Support for Ruby 1.9.3

### Changed
- Upgrade to Rubocop 0.40 and cleanup
- Pin to `json < 2.0.0` to workaround test failures on Ruby 2.3.0

## [0.4.0] - 2016-04-26
### Changed
- Rename http-json-graphite -> metrics-json-graphite

## [0.3.0] - 2016-04-08
### Added
- Add `metrics-http-json-deep` plugin that generates metrics from a JSON endpoint
- Support POST requests in `check-http.rb`
- Support comma+space-separated headers in `check-http.rb`
- Add a Test Kitchen config and BATS tests for CI
- `metrics-curl` now returns the http_code from the request
- `metrics-curl` will now exit with a warning if the curl call returns non zero
- Add Ruby 2.3 to travis tests
- Add usage examples for `check-http`

### Fixed
- Fix Ruby 2.3 deprecation warning on use of timeout (#35)

### Changed
- Update to rubocop 0.37 and resolve issues

### Removed
- Remove Ruby 2.0 from travis tests

## [0.2.1] - 2015-12-14
### Added
- Added validation check for proxy url option in check-http.rb

### Fixed
- Fixed SSL verification error raised erroneously when using -e flag with check-http.rb

## [0.2.0]- 2015-11-17
### Fixed
- check-http.rb will no longer fail if the plugin timeout is longer than the net/http default timeout
- check-http-json.rb will no longer fail when comparing strings

### Changed
- updated Rubocop to `0.32.1`
- put deps in alpha order
- update documentation links

### Added
- Added a check for last modified time in HTTP headers
- POST mode for check-http-json.rb
- Output a message when check-https-cert.rb cannot establish a connection
- insecure option for check-https-cert.rb to skip SSL cert check

## [0.1.1] - 2015-07-14
### Changed
- updated sensu-plugin gem to 1.2.0

## [0.1.0] - 2015-06-18
- A new non-breaking feature - the ability to print the whole response from the http call done in the check-http.rb check to the sensu alert. This can be done by specifying the ```-w``` or ```--whole-response``` parameters.
- Gitignore was updated with more files from Intellij IDEA

## [0.0.2] - 2015-06-03
- Fix the build

## 0.0.1 - 2015-05-21

### Added
- Initial release

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-http/compare/2.9.0...HEAD
[2.9.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/2.8.4...2.9.0
[2.8.4]: https://github.com/sensu-plugins/sensu-plugins-http/compare/2.8.3...2.8.4
[2.8.3]: https://github.com/sensu-plugins/sensu-plugins-http/compare/2.8.2...2.8.3
[2.8.2]: https://github.com/sensu-plugins/sensu-plugins-http/compare/2.8.1...2.8.2
[2.8.1]: https://github.com/sensu-plugins/sensu-plugins-http/compare/2.8.0...2.8.1
[2.8.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/2.7.0...2.8.0
[2.7.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/2.6.0...2.7.0
[2.6.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/2.5.0...2.6.0
[2.5.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/2.4.0...2.5.0
[2.4.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/2.3.0...2.4.0
[2.3.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/2.2.0...2.3.0
[2.2.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/2.1.0...2.2.0
[2.1.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/2.0.2...2.1.0
[2.0.2]: https://github.com/sensu-plugins/sensu-plugins-http/compare/2.0.1...2.0.2
[2.0.1]: https://github.com/sensu-plugins/sensu-plugins-http/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/1.0.0...2.0.0
[1.0.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/0.4.0...1.0.0
[0.4.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/0.2.1...0.3.0
[0.2.1]: https://github.com/sensu-plugins/sensu-plugins-http/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/0.1.1...0.2.0
[0.1.1]: https://github.com/sensu-plugins/sensu-plugins-http/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/0.0.2...0.1.0
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-http/compare/0.0.1...0.0.2
