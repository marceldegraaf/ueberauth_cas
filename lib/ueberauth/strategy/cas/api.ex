defmodule Ueberauth.Strategy.CAS.API do
  @moduledoc """
  CAS server API implementation.
  """

  use Ueberauth.Strategy
  alias Ueberauth.Strategy.CAS

  @doc "Returns the URL to this CAS server's login page."
  def login_url do
    settings(:base_url) <> "/login"
  end

  @doc "Validate a CAS Service Ticket with the CAS server."
  def validate_ticket(ticket, conn) do
    case HTTPoison.get(validate_url, [], params: %{ticket: ticket, service: callback_url(conn)}) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        cond do
          String.match?(body, ~r/cas:authenticationFailure/) ->
            {:error, error_from_body(body)}
          true ->
            {:ok, CAS.User.from_xml(body)}
        end
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:not_found, "no valid CAS user found"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp error_from_body(body) do
    case Regex.named_captures(~r/code="(?<code>\w+)"/, body) do
      %{"code" => code} -> code
                      _ -> "UNKNOWN_ERROR"
    end
  end

  defp validate_url do
    settings(:base_url) <> "/serviceValidate"
  end

  defp settings(key) do
    {_, settings} = Application.get_env(:ueberauth, Ueberauth)[:providers][:cas]
    settings[key]
  end
end
