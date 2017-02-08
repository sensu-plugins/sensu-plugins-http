#!/usr/bin/env bats

setup() {
  export OLD_RUBY_HOME=$RUBY_HOME
  export OLD_GEM_HOME=$GEM_HOME
  export OLD_GEM_PATH=$GEM_PATH

  unset GEM_HOME
  unset GEM_PATH
  source /etc/profile
  export RUBY_HOME=${MY_RUBY_HOME:-/opt/sensu/embedded}

  INNER_GEM_HOME=$($RUBY_HOME/bin/ruby -e 'print ENV["GEM_HOME"]')
  [ -n "$INNER_GEM_HOME" ] && GEM_BIN=$INNER_GEM_HOME/bin || GEM_BIN=$RUBY_HOME/bin
  export CHECK="$RUBY_HOME/bin/ruby $GEM_BIN/check-http.rb"
  export CHECK_JSON="$RUBY_HOME/bin/ruby $GEM_BIN/check-http-json.rb"
}

teardown() {
  export RUBY_HOME=$OLD_RUBY_HOME
  export GEM_HOME=$OLD_GEM_HOME
  export GEM_PATH=$OLD_GEM_PATH
}

@test "Check a basic site, ok" {
  run $CHECK -h localhost -p /okay
  [ $status = 0 ]
  [ "$output" = "CheckHttp OK: 200, 0 bytes" ]
}

@test "Check a basic site, critical 404" {
  run $CHECK -h localhost -p /notthere
  [ $status = 2 ]
  [ "$output" = "CheckHttp CRITICAL: 404" ]
}

@test "Check a basic site, critical 500" {
  run $CHECK -h localhost -p /ohno
  [ $status = 2 ]
  [ "$output" = "CheckHttp CRITICAL: 500" ]
}

@test "Check a redirect site, ok" {
  run $CHECK -h localhost -p /gooverthere -r
  [ $status = 0 ]
  [ "$output" = "CheckHttp OK: 301, 193 bytes" ]
}

@test "Check a redirect site, warning" {
  run $CHECK -h localhost -p /gooverthere
  [ $status = 1 ]
  [ "$output" = "CheckHttp WARNING: 301" ]
}

@test "Check a site with a POST request, ok" {
  run $CHECK -h localhost -p /postthingshere -m POST -d somejunk
  [ $status = 0 ]
  [ "$output" = "CheckHttp OK: 200, 0 bytes" ]
}

@test "Check a site with a POST request, critical" {
  run $CHECK -h localhost -p /okay -m POST -d somejunk
  [ $status = 2 ]
}

@test "Check a site returns JSON with an 'errors' key containing null" {
  run $CHECK_JSON -h localhost -p /json/okay -K errors -v null
  [ $status = 0 ]
}
