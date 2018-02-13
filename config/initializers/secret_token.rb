config_filename = File.join(File.dirname(File.expand_path(__FILE__)), '..', 'secret_token.yml')
#secret_token_config = YAML.load_file(config_filename)

# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
EchoOpensearch::Application.config.secret_key_base = '69178fcac03379251a9b3a0a75c237a5960cb3cce6746477988199eb2cc9be01720a50d3d12121dc3367359a4eb7e56feb3b44033f3609c8bdb61ae830b4206f'
