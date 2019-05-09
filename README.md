# Überauth CAS Strategy

[![Build](https://travis-ci.org/LoyaltyNZ/ueberauth_cas.svg?branch=master)](https://travis-ci.org/LoyaltyNZ/ueberauth_cas)
[![Coverage](https://coveralls.io/repos/github/LoyaltyNZ/ueberauth_cas/badge.svg?branch=master)](https://coveralls.io/github/LoyaltyNZ/ueberauth_cas?branch=master)
[![Documentation](http://inch-ci.org/github/LoyaltyNZ/ueberauth_cas.svg)](http://inch-ci.org/github/LoyaltyNZ/ueberauth_cas)
[![Deps](https://beta.hexfaktor.org/badge/all/github/LoyaltyNZ/ueberauth_cas.svg)](https://beta.hexfaktor.org/github/LoyaltyNZ/ueberauth_cas)

Central Authentication Service strategy for Überauth.

Forked from [https://github.com/marceldegraaf/ueberauth_cas](marceldegraaf/ueberauth_cas) and changed so that it extracts more values from the CAS `serviceResponse`. See `user.ex` for details.

## Installation

  1. Add `ueberauth` and `ueberauth_cas` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        {:ueberauth, "~> 0.2"},
        {:ueberauth_cas, "~> 1.0.0"},
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

## Compatibility

Überauth CAS was tested with the [Casino](http://casino.rbcas.com/) CAS server
implementation. Please let me know if Überauth CAS is incompatible with your CAS
server, and why.
