import Config

# Add Rustler as a dependency
config :h3geo, :rustler_opts,
  otp_app: :h3geo,
  crate: "h3geo"
