defmodule Ueberauth.Strategy.CAS.API do
  @moduledoc """
  CAS server API implementation.
  """

  alias Ueberauth.Strategy.CAS

  import SweetXml

  @doc "Validate a CAS Service Ticket with the CAS server."
  def validate_ticket(ticket, validate_url, service, opts \\ []) do
    validate_url
    |> HTTPoison.get([], params: %{ticket: ticket, service: service})
    |> handle_validate_ticket_response(opts)
  end

  defp handle_validate_ticket_response(
         {:ok, %HTTPoison.Response{status_code: 200, body: body}},
         opts
       ) do
    # We catch XML parse errors, but they will still be shown in the logs.
    # Therefore, we must first parse quietly and then use xpath.
    # See https://github.com/kbrw/sweet_xml/issues/48
    try do
      case xpath(parse(body, quiet: true), ~x"//cas:serviceResponse/cas:authenticationSuccess") do
        nil -> {:error, error_from_body(body)}
        _ -> {:ok, CAS.User.from_xml(body, opts)}
      end
    catch
      :exit, {_type, reason} ->
        {:error, {"malformed_xml", "Malformed XML response: #{inspect(reason)}"}}
    end
  end

  defp handle_validate_ticket_response({:error, %HTTPoison.Error{reason: reason}}, _opts) do
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
end
