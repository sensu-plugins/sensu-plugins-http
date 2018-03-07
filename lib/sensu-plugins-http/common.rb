# frozen_string_literal: true

module Common
  def initialize
    super()
    aws_config
  end

  def aws_config
    if config[:aws_access_key_id] && config[:aws_secret_access_key]
      Aws.config.update(
        credentials: Aws::Credentials.new(config[:aws_access_key_id], config[:aws_secret_access_key])
      )
    end

    Aws.config.update(
      region: config[:aws_region]
    )
  end

  def merge_s3_config
    return if config[:s3_config_bucket].nil? || config[:s3_config_key].nil?

    aws_config

    s3 = Aws::S3::Client.new
    begin
      resp = s3.get_object(bucket: config[:s3_config_bucket], key: config[:s3_config_key])
      s3_config = JSON.parse(resp.body.read, symbolize_names: true)
      config.merge!(s3_config)
    rescue StandardError
      critical 'Error getting config file from s3'
    end
  end
end
