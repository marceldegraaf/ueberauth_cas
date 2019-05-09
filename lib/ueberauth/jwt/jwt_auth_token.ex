defmodule Ueberauth.JWT.JwtAuthToken do
  def decode(jwt_string, public_key_string) do
    jwt_string
    |> Joken.token()
    |> Joken.with_validation("exp", &(&1 > Joken.current_time()))
    |> Joken.with_signer(signer(public_key_string))
    |> Joken.verify()
  end

  defp signer(public_key_string) do
    public_key_string
    |> signing_key
    |> Joken.es256()
  end

  defp signing_key(public_key_string) do
    {_, key_map} =
      public_key_string
      |> JOSE.JWK.from_pem()
      |> JOSE.JWK.to_map()

    key_map
  end
end
