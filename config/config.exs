import Config

# Add Rustler as a dependency
config :h3geo, :rustler_opts,
  otp_app: :h3geo,
  crate: "h3geo"

# Configure rustler_precompiled
config :rustler_precompiled,
  version: "0.7.1"
