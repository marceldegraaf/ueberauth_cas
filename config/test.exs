use Mix.Config

config :ueberauth, Ueberauth,
  providers: [
    cas: {
      Ueberauth.Strategy.CAS,
      [
        base_url: "http://cas.example.com",
        service: "http://svc.example.com",
        jwt_role: "crew"
      ]
    }
  ]

# Put the PUBLIC key that is used to sign JWTs here
config :joken,
  rs512: [
    signer_alg: "RS512",
    key_pem: """
    -----BEGIN PUBLIC KEY-----
    MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxm6F1IB7aDvGd6oTWZga
    jrIBfXzE0DSKyxrKvBaoaVlPQIznwIfIfYWnoFuhkwPI384Oq3K7gpj3JoIBJu72
    vvczBg3JhxCPzolRGC5XmKJxbTq/tbqxgwqx43SG7fK/oh0mZYuKV83rsAikhxOo
    dIaKaQsxxjGIKWkxinEquaLSPQpIEingYpAmL983nGw1pjLY1PR6ltOCpDCjH2YK
    2wcfC7JqBd6Qvh9+kIiM1RZU3+xpB6bhOaB/fddHtQUMNDdaXHkzNg0MtE3NbU9F
    Yh8uv2nNFELEayBRPIfCXkkbV0gua0x+/pj8BP35pvj4Tf4Inodwfn4JrirszNBk
    YQIDAQAB
    -----END PUBLIC KEY-----
    """
  ]
