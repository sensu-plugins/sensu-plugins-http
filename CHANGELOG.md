# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed [here](https://github.com/sensu-plugins/community/blob/master/HOW_WE_CHANGELOG.md)

## [Unreleased]

## [6.1.0] - 2020-04-03
### Added
- `metrics-http-json.rb`: Added `-H/--header` flag to pass custom HTTP headers. (@mblaettler)


## [6.0.1] - 2020-01-30
### Fixed
- `metrics-curl.rb`: improved platform support for detecting `curl` using `which` due to inconsistent options across non bash shells, tested on `bash` and `dash` shells (@elfranne)

## [6.0.0] - 2020-01-17
### Added
- New metrics-libcurl.rb  metrics check that works directly with libcurl and does not need curl executable on system. Very useful as an asset in containerized Sensu Agent installs.
- `check-http.rb`: Add `HEAD` to method options
- `check-http.rb` Added option to include file with multiple headers, useful for long list of headers.

### Fixed
- Updated asset build automation for Alpine target to ensure curl and libcurl based metrics work.
- `check-http.rb`: An empty response body when using `-w` no longer creates a potentially confusing `no implicit conversion of nil into String` error

### Changed
- Updated bundler development dependancy to '~> 2.1'
- Make rake Kitchen tasks conditional on ability to load kitchen module in development env.  kitchen module will not load on hosts without docker runtime.
- Update asset build definitions to match targets supported by ruby-runtime
- Updated test-kitchen development dependancy from '~> 1.23.5' to '~> 1.25.0'
- Updated rubocop requirement 'from ~> 0.51.0' to '~> 0.79.0'
- Updated rake requirement from '~> 12.3' to '~> 13.0'
- Updated rest-client runtime requirement from '~> 2.0.2' to '~> 2.1'
- Make rdoc a development requirement for ruby installations that package rdoc as a gem instead of as part of base ruby
- Updated metrics-curl.rb to check for existance of curl executable in PATH. If not found, reports critical error with message.

### Breaking Change
- Updated json requirement from '< 2.0.0' to '~> 2.3'
- Updated oj requirement from '~> 2.18' to '~> 3.10'

## [5.1.1] - 2019-06-21
### Fixed
- Fix issue with JSON.parse referencing sensu-plugin subclass instead of top level ::JSON module as intended
- Fix missing runtime dependancy on oj needed for metrics-http-json-deep.rb

## [5.1.0] - 2019-05-06
### Added
metrics-http-json.rb: Added the option to disable ssl cert verification
metrics-http-json.rb: Added debug option to see the processing of json data

## [5.0.0] - 2019-04-18
### Breaking Changes
- Bump `sensu-plugin` dependency from `~> 3.0` to `~> 4.0` you can read the changelog entries for [4.0](https://github.com/sensu-plugins/sensu-plugin/blob/master/CHANGELOG.md#400---2018-02-17)
- Disable kitchen tests

### Added
- Travis build automation to generate Sensu Asset tarballs that can be used n conjunction with Sensu provided ruby runtime assets and the Bonsai Asset Index


## [4.1.0] - 2019-02-17
### Added
- `check-http.rb`: Add options to set `--open-timeout` and `--read-timeout` for Net:HTTP. Additionally rescue `Net::OpenTimeout` and `Net::ReadTimeout` exception classes (@johanek)
- `check-http.rb`: exposed `--dns-timeout` for Ruby DNS Resolver. (@johanek)

### Changed
- `check-http.rb`: switched to using rubies DNS resolver to allow catching DNS failures when Net::HTTP establishes connection. (@johanek)

### Removed
- removed codeclimate (@tmonk42)

## [4.0.0] - 2018-12-17
### Breaking Changes
- bumped dependency of `sensu-plugin` to `~> 3.0` (@dependabot) @majormoses

## [3.0.1] - 2018-09-04
### Fixed
- `metrics-http-json-deep.rb`: properly filter out non numeric values (@CosmoPennypacker)

## [3.0.0] - 2018-08-19
### Breaking Changes
- removed ruby `< 2.3` support as they are EOL per our support [policy](https://github.com/sensu/sensu-docs/blob/master/content/plugins/1.0/faq.md#what-is-the-policy-on-supporting-end-of-lifeeol-ruby-versions) (@majormoses)
- bumped dependency of `sensu-plugin` to 2.x you can read about it  [here](https://github.com/sensu-plugins/sensu-plugin/blob/master/CHANGELOG.md#v145---2017-03-07) (@majormoses)

### Changed
- `metrics-http-json-deep.rb`: add option `--floats` to control the number of decimal places (default to 4), for use with `--number` (@CosmoPennypacker)

## [2.11.0] - 2018-06-04
### Added
- `check-http-json.rb`: add option `--response-code` for checking the HTTP response code
- `check-http.rb`: modify option `--response-code` to accept a regex

## [2.10.0] - 2018-05-23
### Added
- `check-http.rb`: add option `--min-bytes` to check if a response is greater than minimum specified value (@lisfo4ka)

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

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-http/compare/6.1.0...HEAD
[6.1.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/6.0.1...6.1.0
[6.0.1]: https://github.com/sensu-plugins/sensu-plugins-http/compare/6.0.0...6.0.1
[6.0.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/5.1.1...6.0.0
[5.1.1]: https://github.com/sensu-plugins/sensu-plugins-http/compare/5.1.0...5.1.1
[5.1.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/5.0.0...5.1.0
[5.0.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/4.1.0...5.0.0
[4.1.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/4.0.0...4.1.0
[4.0.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/3.0.1...4.0.0
[3.0.1]: https://github.com/sensu-plugins/sensu-plugins-http/compare/3.0.0...3.0.1
[3.0.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/2.11.0...3.0.0
[2.11.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/2.10.0...2.11.0
[2.10.0]: https://github.com/sensu-plugins/sensu-plugins-http/compare/2.9.0...2.10.0
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
