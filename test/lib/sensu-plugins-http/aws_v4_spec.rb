require 'aws-sdk'
require_relative '../../spec_helper.rb'
require_relative '../../../lib/sensu-plugins-http/aws-v4'

describe 'AwsV4' do
  before :all do
    @fake_http = Struct.new(:use_ssl?, :address, :port)
  end

  before :each do
    ENV['AWS_REGION'] = nil
    ENV['AWS_ACCESS_KEY_ID'] = nil
    ENV['AWS_SECRET_ACCESS_KEY'] = nil
    ENV['AWS_SESSION_TOKEN'] = nil

    @aws_v4 = Object.new
    @aws_v4.extend(SensuPluginsHttp::AwsV4)

    @time_now = Time.utc(2015, 07, 06, 16, 48, 57)
    allow(Time).to receive(:now).and_return(@time_now)
  end

  describe '#apply_v4_signature' do
    it 'should apply v4 signature headers' do
      ENV['AWS_REGION'] = 'us-east-2'
      ENV['AWS_ACCESS_KEY_ID'] = 'FFFFFFFFFFFFFFFFFFFF'
      ENV['AWS_SECRET_ACCESS_KEY'] = 'fakesecretaccesskeythatsnotgoodforaccess'

      http = @fake_http.new(true, 'myapi.tacos', 443)
      req = Net::HTTP::Get.new('/health?queryParam=true', 'User-Agent' => 'test-ua')

      new_req = @aws_v4.apply_v4_signature(http, req)

      date = '20150706T164857Z'
      content_sha = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
      authorization = 'AWS4-HMAC-SHA256 ' \
                      'Credential=FFFFFFFFFFFFFFFFFFFF/20150706/us-east-2/execute-api/aws4_request, ' \
                      'SignedHeaders=accept-encoding;host;x-amz-content-sha256;x-amz-date, ' \
                      'Signature=430e7b7fbb191322aa16d864743a8df23ed1fb22d93762451d6ecf8a058bde90'

      expect(new_req['x-amz-date']).to eq(date)
      expect(new_req['x-amz-content-sha256']).to eq(content_sha)
      expect(new_req['authorization']).to eq(authorization)
    end
  end
end
