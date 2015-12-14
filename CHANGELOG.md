#Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## Unreleased
- Added validation check for proxy url option

## 0.2.0 - 2015-11-17

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

## 0.1.0 - 2015-06-18
- A new non-breaking feature - the ability to print the whole response from the http call done in the check-http.rb check to the sensu alert. This can be done by specifying the ```-w``` or ```--whole-response``` parameters.
- Gitignore was updated with more files from Intellij IDEA

## 0.0.2 - 2015-06-03
- Fix the build

## 0.0.1 - 2015-05-21

### Added
- Initial release
