# Überauth CAS Strategy

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
