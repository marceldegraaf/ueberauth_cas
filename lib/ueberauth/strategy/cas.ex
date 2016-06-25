defmodule Ueberauth.Strategy.CAS do
  @moduledoc """
  CAS Strategy for Überauth
  """

  use Ueberauth.Strategy

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra
  alias Ueberauth.Strategy.CAS

  def handle_request!(conn) do
    redirect!(conn, redirect_url(conn))
  end

  def handle_callback!(%Plug.Conn{params: %{"ticket" => ticket}} = conn) do
    conn
    |> handle_ticket(ticket)
  end

  def handle_callback!(conn) do
    conn |> set_errors!([error("missing_ticket", "No service ticket received")])
  end

  def handle_cleanup!(conn) do
    conn
    |> put_private(:cas_ticket, nil)
    |> put_private(:cas_user, nil)
  end

  def uid(conn), do: conn.private.cas_user.email

  def extra(conn) do
    %Extra{
      raw_info: %{
        user: conn.private.cas_user
      }
    }
  end

  def info(conn) do
    user = conn.private.cas_user

    %Info{
      name: user.name,
      email: user.email
    }
  end

  def credentials(conn) do
    %Credentials{
      expires: false,
      token: conn.private.cas_ticket,
      other: conn.private.cas_user.roles,
    }
  end

  defp redirect_url(conn) do
    CAS.Server.login_url <> "?service=#{callback_url(conn)}"
  end

  defp handle_ticket(conn, ticket) do
    conn
    |> put_private(:cas_ticket, ticket)
    |> fetch_user(ticket)
  end

  defp fetch_user(conn, ticket) do
    ticket
    |> CAS.Server.validate_ticket
    |> handle_response(conn)
  end

  defp handle_response({:ok, %CAS.ValidateTicketResponse{status_code: status_code, user: user}}, conn) when status_code in 200..399 do
    IO.inspect(user)

    conn
    |> put_private(:cas_user, user)
  end

end
