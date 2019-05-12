defmodule Ueberauth.JWT.JwtAuthToken do
  use Joken.Config, default_signer: :rs512
  alias Ueberauth.Strategy.CAS

  require Logger
  # Verify that the JWT["roles"] claim contains the 'jwt_role' configuration value
  # ie: Does this user posess the correct role
  @impl true
  def token_config do
    Logger.info("JWT check has role '#{CAS.API.jwt_role()}'")

    default_claims()
    |> add_claim("roles", fn -> [] end, &Enum.member?(&1, CAS.API.jwt_role()))
  end
end
