# Überauth CAS Strategy

[![Build](https://travis-ci.org/marceldegraaf/ueberauth_cas.svg?branch=master)](https://travis-ci.org/marceldegraaf/ueberauth_cas)
[![Coverage](https://coveralls.io/repos/github/marceldegraaf/ueberauth_cas/badge.svg?branch=master)](https://coveralls.io/github/marceldegraaf/ueberauth_cas?branch=master)
[![Module Version](https://img.shields.io/hexpm/v/ueberauth_cas.svg)](https://hex.pm/packages/ueberauth_cas)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ueberauth_cas/)
[![Total Download](https://img.shields.io/hexpm/dt/ueberauth_cas.svg)](https://hex.pm/packages/ueberauth_cas)
[![License](https://img.shields.io/hexpm/l/ueberauth_cas.svg)](https://github.com/marceldegraaf/ueberauth_cas/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/marceldegraaf/ueberauth_cas.svg)](https://github.com/marceldegraaf/ueberauth_cas/commits/master)

Central Authentication Service (CAS) strategy for Überauth.

## Installation

1. Add `:ueberauth` and `:ueberauth_cas` to your list of dependencies in `mix.exs`:

   ```elixir
   def deps do
     [
       {:ueberauth, "~> 0.7"},
       {:ueberauth_cas, "~> 2.0"}
     ]
   end
   ```

2. Ensure `:ueberauth_cas` is started before your application:

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
       # sanitize_attribute_names: false,
       # multivalued_attributes: :first,
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

## Copyright and License

Copyright (c) 2016 Marcel de Graaf

This library is licensed under the [MIT license](./LICENSE.md).
