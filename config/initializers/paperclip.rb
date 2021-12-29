if Rails.env.production?
  Paperclip::Attachment.default_options[:storage] = :s3
  Paperclip::Attachment.default_options[:s3_credentials] = {
    bucket: ENV['S3_BUCKET_NAME'],
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    s3_region: ENV['S3_REGION']
  }
  Paperclip::HttpUrlProxyAdapter.register
elsif Rails.env.development?
  Paperclip::HttpUrlProxyAdapter.register
end
