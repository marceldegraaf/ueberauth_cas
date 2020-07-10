defmodule Ueberauth.Strategy.CAS.User do
  @moduledoc """
  Representation of a CAS user with their roles.
  """

  defstruct name: nil, email: nil, roles: nil

  alias Ueberauth.Strategy.CAS.User

  def from_xml(body) do
    %User{}
    |> set_name(body)
    |> set_email(body)
    |> set_roles(body)
  end

  defp set_name(user, body),   do: %User{user | name: email(body)}
  defp set_email(user, body),  do: %User{user | email: email(body)}
  defp set_roles(user, _body), do: %User{user | roles: ["developer", "admin"]}

  defp email(body) do
    Floki.parse_fragment!(body)
    |> Floki.find("cas|user")
    |> List.first
    |> Tuple.to_list
    |> List.last
    |> List.first
    |> String.downcase
  end
end
