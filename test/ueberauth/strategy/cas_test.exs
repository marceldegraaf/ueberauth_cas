defmodule Ueberauth.Strategy.CAS.Test do
  use ExUnit.Case
  use Plug.Test
  import Mock

  alias Ueberauth.Strategy.CAS

  setup do
    conn = %Plug.Conn{
      private: %{
        cas_user: %CAS.User{name: "Marcel de Graaf", attributes: %{"email" => "mail@marceldegraaf.net", "roles" => ["developer"], "first_name" => ["Joe", "Example"]}},
        cas_ticket: "ST-XXXXX",
      }
    }

    ok_xml = """
    <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
      <cas:authenticationSuccess>
        <cas:user>mail@marceldegraaf.net</cas:user>
        <cas:attributes>
          <cas:authenticationDate>2016-06-29T21:53:41Z</cas:authenticationDate>
          <cas:longTermAuthenticationRequestTokenUsed>false</cas:longTermAuthenticationRequestTokenUsed>
          <cas:isFromNewLogin>true</cas:isFromNewLogin>
          <cas:roles>developer</cas:roles>
          <cas:roles>admin</cas:roles>
        </cas:attributes>
      </cas:authenticationSuccess>
    </cas:serviceResponse>
    """

    error_xml = """
    <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
      <cas:authenticationFailure code="INVALID_TICKET">Ticket 'ST-XXXXX' already consumed</cas:authenticationFailure>
    </cas:serviceResponse>
    """

    {
      :ok,
      conn: conn,
      ok_xml: ok_xml,
      error_xml: error_xml,
    }
  end

  test "redirect callback redirects to login url" do
    conn = conn(:get, "/login") |> CAS.handle_request!

    assert conn.status == 302
  end

  test "login callback without service ticket shows an error" do
    conn = CAS.handle_callback!(%Plug.Conn{params: %{}})
    assert Map.has_key?(conn.assigns, :ueberauth_failure)
  end

  test "successful login callback validates the ticket", %{ok_xml: xml} do
    with_mock HTTPoison, [
      get: fn(_url, _opts, _params) ->
        {:ok, %HTTPoison.Response{status_code: 200, body: xml, headers: []}
      } end
    ] do
      conn = CAS.handle_callback!(%Plug.Conn{params: %{"ticket" => "ST-XXXXX"}})

      assert conn.private.cas_ticket == "ST-XXXXX"
      assert conn.private.cas_user.email == "mail@marceldegraaf.net"
      assert conn.private.cas_user.name == "mail@marceldegraaf.net"
    end
  end

  test "invalid login callback returns an error", %{error_xml: xml} do
    with_mock HTTPoison, [
      get: fn(_url, _opts, _params) ->
        {:ok, %HTTPoison.Response{status_code: 200, body: xml, headers: []}
      } end
    ] do
      conn = CAS.handle_callback!(%Plug.Conn{params: %{"ticket" => "ST-XXXXX"}})

      assert List.first(conn.assigns.ueberauth_failure.errors).message_key == "INVALID_TICKET"
      assert List.first(conn.assigns.ueberauth_failure.errors).message == "Ticket 'ST-XXXXX' already consumed"
    end
  end

  test "cleanup callback", %{conn: conn} do
    conn = CAS.handle_cleanup!(conn)

    assert conn.private.cas_user == nil
    assert conn.private.cas_ticket == nil
  end

  test "use user email as uniqe uid", %{conn: conn} do
    uid = CAS.uid(conn)

    assert uid == "Marcel de Graaf"
  end
  
  describe "info struct" do
    test "basic struct is generated", %{conn: conn} do
      info = CAS.info(conn)

      assert info.name == "Marcel de Graaf"
      assert info.email == "mail@marceldegraaf.net"
    end

    test "multiple info works", %{conn: conn} do
      info = CAS.info(conn)

      assert info.name == "Marcel de Graaf"
      assert info.first_name == "Joe"
    end
  end

  test "generates credentials struct", %{conn: conn} do
    credentials = CAS.credentials(conn)

    assert credentials.expires == false
    assert credentials.token == "ST-XXXXX"
    assert credentials.other == ["developer"]
  end

  test "generates extra struct", %{conn: conn} do
    extra = CAS.extra(conn)

    assert extra.raw_info.user == conn.private.cas_user
  end
end
