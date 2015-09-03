
module Common
  def initialize
    super()
    aws_config
  end

  def aws_config
    Aws.config.update(
      credentials: Aws::Credentials.new(config[:aws_access_key], config[:aws_secret_access_key])
    ) if config[:aws_access_key] && config[:aws_secret_access_key]

    Aws.config.update(
      region: config[:aws_region]
    )
  end

  def merge_s3_config
      if config[:s3_config_bucket] != nil && config[:s3_config_key] != nil
          s3 = Aws::S3::Client.new
          begin
              resp = s3.get_object(bucket:config[:s3_config_bucket], key:config[:s3_config_key])
              s3_config = JSON.parse(resp.body.read, symbolize_names: true)
              config.merge!(s3_config)
          rescue => e
              critical "Error getting config file from s3"
          end
      end
  end

end
