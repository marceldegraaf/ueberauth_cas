# Überauth CAS Strategy

[![Build](https://travis-ci.org/marceldegraaf/ueberauth_cas.svg?branch=master)](https://travis-ci.org/marceldegraaf/ueberauth_cas)
[![Coverage](https://coveralls.io/repos/github/marceldegraaf/ueberauth_cas/badge.svg?branch=master)](https://coveralls.io/github/marceldegraaf/ueberauth_cas?branch=master)
[![Documentation](http://inch-ci.org/github/marceldegraaf/ueberauth_cas.svg)](http://inch-ci.org/github/marceldegraaf/ueberauth_cas)
[![Hex.pm](https://img.shields.io/hexpm/v/ueberauth_cas.svg?maxAge=2592000)](https://hex.pm/packages/ueberauth_cas)

Central Authentication Service strategy for Überauth.

## Installation

1. Add `ueberauth` and `ueberauth_cas` to your list of dependencies in `mix.exs`:

   ```elixir
   def deps do
     [
       {:ueberauth, "~> 0.2"},
       {:ueberauth_cas, "~> 2.0.0"}
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
       callback_url: "http://your-app.example.com/auth/cas/callback",
     ]}]
   ```

4. Include the Überauth plug in your controller:

   ```elixir
   defmodule MyApp.AuthController do
     use MyApp.Web, :controller
     plug Ueberauth
     ...
   end
   ```

5. Create the request and callback routes if you haven't already:

   ```elixir
   scope "/auth", MyApp do
     pipe_through :browser

     get "/:provider", AuthController, :request
     get "/:provider/callback", AuthController, :callback
   end
   ```

6. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

## Compatibility

Überauth CAS was tested with the [Casino](http://casino.rbcas.com/) CAS server
implementation. Please let me know if Überauth CAS is incompatible with your CAS
server, and why.

The docs contain more information about protocol specifics.
