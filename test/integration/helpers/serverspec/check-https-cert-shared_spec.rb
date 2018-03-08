# frozen_string_literal: true

require 'spec_helper'
require 'shared_spec'

gem_path = '/usr/local/bin'
check_name = 'check-https-cert.rb'
check = "#{gem_path}/#{check_name}"
# domain = 'localhost'

describe 'ruby environment' do
  it_behaves_like 'ruby checks', check
end

# asert that expired certs are criticals
describe command("#{check} --url https://expired.badssl.com --insecure") do
  its(:exit_status) { should eq 2 }
  its(:stdout) { should match(/CheckHttpCert CRITICAL: TLS\/SSL certificate expired [0-9]+ days ago/) }
end

# asert that a self signed cert fails when not using insecure mode
describe command("#{check} --url https://expired.badssl.com") do
  its(:exit_status) { should eq 2 }
  its(:stdout) { should match(/CheckHttpCert CRITICAL: Could not connect to https:\/\/expired.badssl.com/) }
end

# assert the cert is expired and thats somehow OK?
describe command("#{check} --url https://expired.badssl.com --insecure --expired") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/CheckHttpCert OK: TLS\/SSL certificate expired [0-9]+ days ago/) }
end
