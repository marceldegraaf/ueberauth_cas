# Überauth CAS + JWT Strategy

[![Build](https://travis-ci.org/LoyaltyNZ/ueberauth_cas_jwt.svg?branch=master)](https://travis-ci.org/LoyaltyNZ/ueberauth_cas_jwt)
[![Coverage](https://coveralls.io/repos/github/LoyaltyNZ/ueberauth_cas_jwt/badge.svg?branch=master)](https://coveralls.io/github/LoyaltyNZ/ueberauth_cas_jwt?branch=master)
[![Documentation](http://inch-ci.org/github/LoyaltyNZ/ueberauth_cas_jwt.svg)](http://inch-ci.org/github/LoyaltyNZ/ueberauth_cas_jwt)
[![Deps](https://beta.hexfaktor.org/badge/all/github/LoyaltyNZ/ueberauth_cas_jwt.svg)](https://beta.hexfaktor.org/github/LoyaltyNZ/ueberauth_cas_jwt)

Central Authentication Service strategy for Überauth.

Forked from [https://github.com/marceldegraaf/ueberauth_cas](marceldegraaf/ueberauth_cas) and altered so that it extracts a JWT from the CAS `serviceResponse`, and decodes and verifies it. See `user.ex` for details.

## Installation

  1. Add `ueberauth` and `ueberauth_cas_jwt` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        {:ueberauth, "~> 2.0"},
        {:ueberauth_cas_jwt, "~> 0.0.1"},
      ]
    end
    ```

  2. Ensure `ueberauth_cas_jwt` is started before your application:

    ```elixir
    def application do
      [extra_applications: [:ueberauth_cas_jwt]]
    end
    ```

  3. Configure the CAS integration in `config/config.exs`:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [cas: {Ueberauth.Strategy.CAS, [
        base_url: "http://cas.example.com",
        callback: "http://your-app.example.com/auth/cas/callback",
        jwt_role: "crew",
      ]}]
    ```

  4. Configure the JWT configuration in `config/config.exs`:

    ```elixir
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
    ```

  5. In `AuthController` use the CAS strategy in your `login/4` function:

    ```elixir
    def login(conn, _params, _current_user, _claims) do
      conn
      |> Ueberauth.Strategy.CAS.handle_request!
    end
    ```

## Compatibility

Überauth CAS was tested with the [Casino](http://casino.rbcas.com/) CAS server
implementation. Please let me know if Überauth CAS is incompatible with your CAS
server, and why.
