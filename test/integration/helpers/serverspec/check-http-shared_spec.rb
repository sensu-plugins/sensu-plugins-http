# frozen_string_literal: true

require 'spec_helper'
require 'shared_spec'

gem_path = '/usr/local/bin'
check_name = 'check-http.rb'
check = "#{gem_path}/#{check_name}"
domain = 'localhost'

describe 'ruby environment' do
  it_behaves_like 'ruby checks', check
end

# an expected 200 is OK
describe command("#{check} --url http://#{domain}/okay") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/CheckHttp OK: 200, [0-9]+ bytes/) }
end

# a 404 is a CRITICAL
describe command("#{check} --url http://#{domain}/nothere") do
  its(:exit_status) { should eq 2 }
  its(:stdout) { should match(/CheckHttp CRITICAL: 404/) }
end

# a 500 is a CRITICAL
describe command("#{check} --url http://#{domain}/ohno") do
  its(:exit_status) { should eq 2 }
  its(:stdout) { should match(/CheckHttp CRITICAL: 500/) }
end

# a 3xx is an unknown
describe command("#{check} --url http://#{domain}/gooverthere") do
  its(:exit_status) { should eq 1 }
  its(:stdout) { should match(/CheckHttp WARNING: 301/) }
end

# connection refused
describe command("#{check} --url https://#{domain}/okay") do
  its(:exit_status) { should eq 2 }
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.3.0')
    its(:stdout) { should match(/CheckHttp CRITICAL: Request error: Failed to open TCP connection to localhost:443/) }
  else
    its(:stdout) { should match(/CheckHttp CRITICAL: Request error: Cannot assign requested address - connect\(2\) for "localhost" port 443/) }
  end
end
