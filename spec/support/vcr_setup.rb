VCR.configure do |c|
  # By default VCR will intercept all http calls. We don't want it to intercept echo-access calls, just catalog-rest and echo-rest.
  c.ignore_hosts '127.0.0.1', 'localhost'
  # The directory where your cassettes will be saved
  c.cassette_library_dir = 'spec/fixtures'
  #c.preserve_exact_body_bytes do |http_message|
  #  http_message.body.encoding.name == 'UTF-8' ||
  #      !http_message.body.valid_encoding?
  #end
  # force UTF 8 encoding since binary cannot be correctly decoded in some cases
  #c.before_record do |i|
  #  i.response.body.force_encoding('UTF-8')    #'UTF-8' or 'ASCII-8BIT'
  #end
  c.hook_into :webmock
end