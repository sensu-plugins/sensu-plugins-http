#!/usr/bin/env bats

setup() {
  export CHECK="sudo -u sensu /opt/sensu/embedded/bin/check-http.rb"
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
  run $CHECK -h localhost -p /postthingshere -m POST -b somejunk
  [ $status = 0 ]
  [ "$output" = "CheckHttp OK: 200, 0 bytes" ]
}

@test "Check a site with a POST request, critical" {
  run $CHECK -h localhost -p /okay -m POST -b somejunk
  [ $status = 2 ]
}
