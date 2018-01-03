defmodule Ueberauth.Strategy.CAS.User do
  @moduledoc """
  Representation of a CAS user with their roles.
  """

  import SweetXml

  defstruct name: nil, email: nil, roles: nil, attributes: nil

  alias Ueberauth.Strategy.CAS.User

  def from_xml(body) do
    %User{}
    |> set_name(body)
    |> set_attributes(body)
    |> set_email
    |> set_roles
  end

  defp set_attributes(user, body) do
    %User{user | attributes:
      body
      |> xpath(~x"//cas:attributes/*"l)
      |> Enum.reduce(%{}, fn (node, attributes) ->
        attributes
        |> Map.put(get_attribute_name(node), get_attribute_value(node))
      end)
    }
  end

  defp set_name(user, body) do
    %User{user | name: body |> xpath(~x"//cas:user/text()"s) |> String.downcase}
  end

  defp set_email(user) do
    %User{user | email: user.attributes["email"] || user.name}
  end

  defp set_roles(user) do
    %User{user | roles: user.attributes["roles"] || ["developer", "admin"]}
  end

  defp get_attribute_name(node) do
    node
    |> xpath(~x"name(.)"s)
    |> String.replace("{http://www.yale.edu/tp/cas}", "")
    |> Macro.underscore
  end

  defp get_attribute_value(node) do
    node
    |> xpath(~x"./text()"s)
    |> cast_value
  end

  defp cast_value(value) do
    cond do
      value == "true"   -> true
      value == "false"  -> false
      String.match?(value, ~r/---/) -> decode_yaml(value)
      true -> value
    end
  end

  defp decode_yaml(value) do
    ~r/---(?<yaml>.+)/ms
    |> Regex.named_captures(value)
    |> Map.get("yaml")
    |> YamlElixir.read_from_string
  end

end
