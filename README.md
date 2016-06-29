# Überauth CAS Strategy

[![Build](https://travis-ci.org/marceldegraaf/ueberauth_cas.svg?branch=master)](https://travis-ci.org/marceldegraaf/ueberauth_cas)
[![Coverage](https://coveralls.io/repos/github/marceldegraaf/ueberauth_cas/badge.svg?branch=master)](https://coveralls.io/github/marceldegraaf/ueberauth_cas?branch=master)
[![Documentation](http://inch-ci.org/github/marceldegraaf/ueberauth_cas.svg)](http://inch-ci.org/github/marceldegraaf/ueberauth_cas)
[![Deps](https://beta.hexfaktor.org/badge/all/github/marceldegraaf/ueberauth_cas.svg)](https://beta.hexfaktor.org/github/marceldegraaf/ueberauth_cas)

Central Authentication Service strategy for Überauth.

**NOTE**: this library is under heavy development and should be considered
unstable as long as this notice is in place.

## Installation

  1. Add `ueberauth_cas` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_cas, "~> 0.1.0"}]
    end
    ```

  2. Ensure `ueberauth_cas` is started before your application:

    ```elixir
    def application do
      [applications: [:ueberauth_cas]]
    end
    ```
