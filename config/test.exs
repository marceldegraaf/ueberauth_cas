use Mix.Config

config :ueberauth, Ueberauth,
  providers: [
    cas: {Ueberauth.Strategy.CAS, [base_url: "http://cas.example.com", service: "http://svc.example.com"]}
  ]
