defmodule Ueberauth.Strategy.CAS.Server do
  @moduledoc """
  CAS server API implementation.
  """

  alias Ueberauth.Strategy.CAS

  def login_url do
    settings(:base_url) <> "/login"
  end

  # TODO implement this call
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
