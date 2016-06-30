# Überauth CAS Strategy

[![Build](https://travis-ci.org/marceldegraaf/ueberauth_cas.svg?branch=master)](https://travis-ci.org/marceldegraaf/ueberauth_cas)
[![Coverage](https://coveralls.io/repos/github/marceldegraaf/ueberauth_cas/badge.svg?branch=master)](https://coveralls.io/github/marceldegraaf/ueberauth_cas?branch=master)
[![Documentation](http://inch-ci.org/github/marceldegraaf/ueberauth_cas.svg)](http://inch-ci.org/github/marceldegraaf/ueberauth_cas)
[![Deps](https://beta.hexfaktor.org/badge/all/github/marceldegraaf/ueberauth_cas.svg)](https://beta.hexfaktor.org/github/marceldegraaf/ueberauth_cas)

Central Authentication Service strategy for Überauth.

## Installation

  1. Add `ueberauth` and `ueberauth_cas` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        {:ueberauth, "~> 0.2"},
        {:ueberauth_cas, "~> 0.1.0"},
      ]
    end
    ```

  2. Ensure `ueberauth_cas` is started before your application:

    ```elixir
    def application do
      [applications: [:ueberauth_cas]]
    end
    ```

  3. Configure the CAS integration in `config/config.exs`:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [cas: {Ueberauth.Strategy.CAS, [
        base_url: "http://cas.example.com",
        callback: "http://your-app.example.com/auth/cas/callback",
      ]}]
    ```

  4. In `AuthController` use the CAS strategy in your `login/4` function:

    ```elixir
    def login(conn, _params, _current_user, _claims) do
      conn
      |> Ueberauth.Strategy.CAS.handle_request!
    end
    ```
