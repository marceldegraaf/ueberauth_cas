defmodule Ueberauth.Strategy.CAS.User do
  @moduledoc """
  Representation of a CAS user including the following attributes:
  - user
  - attributes
    - authenticationDate
    - longTermAuthenticationRequestTokenUsed
    - isFromNewLogin
    - sso_user_id
    - jwt
  """

  alias Ueberauth.JWT.JwtAuthToken
  alias Ueberauth.Strategy.CAS

  defstruct user: nil,
            authentication_date: nil,
            long_term_authentication_request_token_used: nil,
            is_from_new_login: nil,
            sso_user_id: nil,
            jwt: nil

  alias Ueberauth.Strategy.CAS.User

  def from_xml(body) do
    %User{}
    |> set_user(body)
    |> set_authentication_date(body)
    |> set_long_term_auth(body)
    |> set_is_from_new_login(body)
    |> set_sso_user_id(body)
    |> set_jwt(body)
    |> IO.inspect()
  end

  defp set_user(user, body) do
    %User{user | user: user(body)}
  end

  defp set_authentication_date(user, body) do
    %User{user | authentication_date: authentication_date(body)}
  end

  defp set_long_term_auth(user, body) do
    %User{user | long_term_authentication_request_token_used: long_term_auth(body)}
  end

  defp set_is_from_new_login(user, body) do
    %User{user | is_from_new_login: is_from_new_login(body)}
  end

  defp set_sso_user_id(user, body) do
    %User{user | sso_user_id: sso_user_id(body)}
  end

  defp set_jwt(user, body) do
    case JwtAuthToken.decode(jwt(body), CAS.API.jwt_public_key()) do
      {:success, jwt} -> Map.merge(user, %{jwt: jwt, jwt_valid: true})
      _ -> Map.merge(user, %{jwt: nil, jwt_valid: false})
    end
  end

  defp user(body) do
    Floki.find(body, "cas|user")
    |> List.first()
    |> Tuple.to_list()
    |> List.last()
    |> List.first()
    |> String.downcase()
  end

  defp authentication_date(body) do
    # Note Floki matches on lowercase element names
    Floki.find(body, "cas|attributes cas|authenticationdate")
    |> List.first()
    |> Tuple.to_list()
    |> List.last()
    |> List.first()
  end

  defp long_term_auth(body) do
    Floki.find(body, "cas|attributes cas|longtermauthenticationrequesttokenused")
    |> List.first()
    |> Tuple.to_list()
    |> List.last()
    |> List.first()
  end

  defp is_from_new_login(body) do
    Floki.find(body, "cas|attributes cas|isfromnewlogin")
    |> List.first()
    |> Tuple.to_list()
    |> List.last()
    |> List.first()
  end

  defp sso_user_id(body) do
    Floki.find(body, "cas|attributes cas|sso_user_id")
    |> List.first()
    |> Tuple.to_list()
    |> List.last()
    |> List.first()
  end

  defp jwt(body) do
    Floki.find(body, "cas|attributes cas|jwt")
    |> List.first()
    |> Tuple.to_list()
    |> List.last()
    |> List.first()
  end
end
