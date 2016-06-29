defmodule Ueberauth.Strategy.CAS.API do
  @moduledoc """
  CAS server API implementation.
  """

  alias Ueberauth.Strategy.CAS

  @doc "Returns the URL to this CAS server's login page."
  def login_url do
    settings(:base_url) <> "/login"
  end

  # TODO implement this call
  @doc "Validate a CAS Service Ticket with the CAS server."
  def validate_ticket(ticket) do
    {
      :ok, %CAS.ValidateTicketResponse{
        status_code: 200,
        user: %CAS.User{name: "Marcel de Graaf", email: "mail@marceldegraaf.net", roles: ["developer", "admin"]}
      }
    }
  end

  defp validate_url do

  end

  defp settings(key) do
    {_, settings} = Application.get_env(:ueberauth, Ueberauth)[:providers][:cas]
    settings[key]
  end
end
