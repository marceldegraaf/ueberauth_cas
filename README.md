# Überauth CAS + JWT Strategy

[![Build](https://travis-ci.org/LoyaltyNZ/ueberauth_cas_jwt.svg?branch=master)](https://travis-ci.org/LoyaltyNZ/ueberauth_cas_jwt)

Central Authentication Service strategy for Überauth.

Forked from [https://github.com/marceldegraaf/ueberauth_cas](marceldegraaf/ueberauth_cas) and altered so that it extracts a JWT from the CAS `serviceResponse`, and decodes and verifies it. See `user.ex` for details.

## Installation

  1. Add `ueberauth` and `ueberauth_cas_jwt` to your list of dependencies in `mix.exs`:

    ```
    def deps do
      [
        {:ueberauth, "~> 2.0"},
        {:ueberauth_cas_jwt, "~> 0.0.1"},
      ]
    end
    ```

  2. Ensure `ueberauth_cas_jwt` is started before your application:

    ```
    def application do
      [extra_applications: [:ueberauth_cas_jwt]]
    end
    ```

  3. Configure the CAS integration in `config/config.exs`:

    ```
    config :ueberauth, Ueberauth,
      providers: [cas: {Ueberauth.Strategy.CAS, [
        base_url: "http://cas.example.com",
        callback: "http://your-app.example.com/auth/cas/callback",
        # Ensute that the JWT 'roles' contains this role
        jwt_role: "crew",
      ]}]
    ```

  4. Configure the JWT configuration in `config/config.exs`:

    ```
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

  5. In your `AuthController` implement the appropriate callbacks for Ueuberauth, eg:

    ```
    defmodule MyAppWeb.AuthController do
      use MyAppWeb, :controller
      plug Ueberauth
      alias Ueberauth.Strategy.Helpers

      # We'll hit this callback if we fail to successfully authenticate via
      # ueberauth.
      def callback(%{assigns: %{ueberauth_failure: fails}} = conn, _params) do
        conn
        |> put_flash(:error, "Failed to authenticate.")
        |> redirect(external: Application.get_env(:console_notify, :console_sso_url))
      end

      # If we have an ueberauth_auth key set, then we successfully authenticated.
      # We will pass this through a model called `UserFromAuth` to generate a map
      # representing our logged in user.  We then store this in the `current_user`
      # session variable.
      def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
        user_params = %{
          sso_user_id: auth.credentials.other[:jwt]["sso_user_id"],
          email: auth.info.email,
          token: auth.credentials.token
        }
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:current_user, user)
        |> redirect(to: "/")
      end
    end
    ```

## Compatibility

Überauth CAS was tested with the [Casino](http://casino.rbcas.com/) CAS server
implementation.
