defmodule Ueberauth.Strategy.CAS.API do
  @moduledoc """
  CAS server API implementation.
  """

  use Ueberauth.Strategy
  alias Ueberauth.Strategy.CAS

  import SweetXml

  @doc "Returns the URL to this CAS server's login page."
  def login_url do
    settings(:base_url) <> "/login"
  end

  @doc "Validate a CAS Service Ticket with the CAS server."
  def validate_ticket(ticket, conn) do
    HTTPoison.get(validate_url(), [], params: %{ticket: ticket, service: callback_url(conn)})
    |> handle_validate_ticket_response()
  end

  defp handle_validate_ticket_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    # We catch XML parse errors, but they will still be shown in the logs.
    # See https://github.com/kbrw/sweet_xml/issues/48
    try do
      case xpath(body, ~x"//cas:serviceResponse/cas:authenticationSuccess") do
        nil -> {:error, error_from_body(body)}
        _ -> {:ok, CAS.User.from_xml(body)}
      end
    catch
      :exit, {_type, reason} -> {:error, {"malformed_xml", "Malformed XML response: #{inspect(reason)}"}}
    end
  end

  defp handle_validate_ticket_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end

  defp sanitize_string(value) when value == "", do: nil
  defp sanitize_string(value), do: value

  defp error_from_body(body) do
    error_code =
      xpath(body, ~x"/*/cas:authenticationFailure/@code")
      |> to_string()
      |> sanitize_string()

    message =
      xpath(body, ~x"/*/cas:authenticationFailure/text()")
      |> to_string()
      |> sanitize_string()

    {error_code || "unknown_error", message || "Unknown error"}
  end

  defp validate_url do
    settings(:base_url) <> "/serviceValidate"
  end

  defp settings(key) do
    {_, settings} = Application.get_env(:ueberauth, Ueberauth)[:providers][:cas]
    settings[key]
  end
end
