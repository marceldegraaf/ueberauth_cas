defmodule Ueberauth.Strategy.CAS.User do
  @moduledoc """
  Representation of a CAS user with their roles.

  A [CAS serviceResponse][response] is either an error message or a success
  message. In the success case, the response often contains various attributes
  containing information about the user.

  For example, a successful request might look like this:

  ```xml
  <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
    <cas:authenticationSuccess>
      <cas:user>example</cas:user>
      <cas:attributes>
        <cas:authenticationDate>2016-06-29T21:53:41Z</cas:authenticationDate>
        <cas:longTermAuthenticationRequestTokenUsed>false</cas:longTermAuthenticationRequestTokenUsed>
        <cas:isFromNewLogin>true</cas:isFromNewLogin>
        <cas:email>test@example.com</cas:email>
      </cas:attributes>
    </cas:authenticationSuccess>
  </cas:serviceResponse>
  ```

  Note that strictly speaking, version 2.0 of CAS does not support attributes.
  The strategy however does not make this distinction: if attributes exist, the strategy will
  use them.

  ## User struct

  Accessing the attributes is possible by accessing the "attributes"
  on the raw information. For example:

  ```elixir
  def extract_attributes(%Ueberauth.Auth{} = auth) do
    attributes = auth.extra.raw_info.user.attributes
    # Do something with the attributes
  end
  ```

  [response]: https://apereo.github.io/cas/6.5.x/protocol/CAS-Protocol-Specification.html#appendix-a-cas-response-xml-schema
  [old]: https://apereo.github.io/cas/6.5.x/protocol/CAS-Protocol-Specification.html#appendix-a-cas-response-xml-schema
  """

  @doc """
  Struct containing information about the user.

  There are two relevant fields:

  - `:name` - The name returned by the serviceResponse
  - `:attributes` - Other attributes returned by the serviceResponse
  """
  defstruct name: nil, attributes: %{}

  alias Ueberauth.Strategy.CAS.User

  import SweetXml

  def from_xml(body, opts \\ []) do
    attributes = get_attributes(body, opts)
    name = get_user(body)

    %User{}
    |> Map.put(:name, name)
    |> Map.put(:attributes, attributes)
  end

  defp get_user(body) do
    xpath(body, ~x"//cas:user/text()") |> to_string()
  end

  defp get_attributes(body, opts) do
    body
    |> xpath(~x"//cas:attributes/*"l)
    |> Enum.reduce(%{}, fn node, attributes ->
      name = get_attribute_name(node, opts)
      value = get_attribute_value(node)
      # If the attribute exists already, convert to list.
      if Map.has_key?(attributes, name) do
        Map.update!(attributes, name, fn existing ->
          if is_list(existing) do
            existing ++ [value]
          else
            [existing, value]
          end
        end)
      else
        Map.put(attributes, name, value)
      end
    end)
  end

  defp get_attribute_value(node) do
    node
    |> xpath(~x"./text()"s)
    |> cast_value
  end

  defp get_attribute_name(node, opts) do
    node
    |> xpath(~x"local-name(.)"s)
    |> sanitize_attribute_name(opts)
  end

  defp sanitize_attribute_name(name, opts) do
    if Keyword.get(opts, :sanitize_attribute_names, true) do
      Macro.underscore(name)
    else
      name
    end
  end

  defp cast_value(value) do
    cond do
      value == "true" -> true
      value == "false" -> false
      true -> value
    end
  end
end
