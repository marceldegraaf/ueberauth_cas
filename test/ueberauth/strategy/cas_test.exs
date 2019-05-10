defmodule Ueberauth.Strategy.CAS.Test do
  use ExUnit.Case
  use Plug.Test
  import Mock

  alias Ueberauth.Strategy.CAS

  setup do
    conn = %Plug.Conn{
      private: %{
        cas_user: %CAS.User{
          user: "email@example.com",
          authentication_date: "2019-05-08T22:49:42Z",
          long_term_authentication_request_token_used: "false",
          is_from_new_login: "true",
          sso_user_id: "d6a7e0c8-661c-4845-894c-4b28befa375f",
          jwt: %{
            "sub" => "d6a7e0c8-661c-4845-894c-4b28befa375f",
            "exp" => 1_557_356_682,
            "username" => "email@example.com",
            "roles" => [
              "merchant_portal",
              "merchant_portal_admin",
              "merchant_admin",
              "configuration",
              "paymarkd",
              "shopper_science",
              "ltp",
              "campaign_track",
              "responsys_file_processor",
              "emr",
              "transactions",
              "notify",
              "crew"
            ],
            "sso_user_id" => "d6a7e0c8-661c-4845-894c-4b28befa375f"
          }
        },
        cas_ticket: "ST-XXXXX"
      }
    }

    ok_xml = """
    <cas:serviceResponse xmlns:cas=\"http://www.yale.edu/tp/cas\">
    <cas:authenticationSuccess>
    <cas:user>email@example.com</cas:user>
    <cas:attributes>
      <cas:authenticationDate>2019-05-08T22:49:42Z</cas:authenticationDate>
      <cas:longTermAuthenticationRequestTokenUsed>false</cas:longTermAuthenticationRequestTokenUsed>
      <cas:isFromNewLogin>true</cas:isFromNewLogin>
      <cas:roles>merchant_portal</cas:roles>
      <cas:roles>merchant_portal_admin</cas:roles>
      <cas:roles>merchant_admin</cas:roles>
      <cas:roles>configuration</cas:roles>
      <cas:roles>paymarkd</cas:roles>
      <cas:roles>shopper_science</cas:roles>
      <cas:roles>ltp</cas:roles>
      <cas:roles>campaign_track</cas:roles>
      <cas:roles>responsys_file_processor</cas:roles>
      <cas:roles>emr</cas:roles>
      <cas:roles>transactions</cas:roles>
      <cas:roles>notify</cas:roles>
      <cas:roles>crew</cas:roles>
      <cas:sso_user_id>d6a7e0c8-661c-4845-894c-4b28befa375f</cas:sso_user_id>
      <cas:jwt>eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzUxMiJ9.eyJzdWIiOiJkNmE3ZTBjOC02NjFjLTQ4NDUtODk0Yy00YjI4YmVmYTM3NWYiLCJleHAiOjE1NTczNTY2ODIsInVzZXJuYW1lIjoiZW1haWxAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJtZXJjaGFudF9wb3J0YWwiLCJtZXJjaGFudF9wb3J0YWxfYWRtaW4iLCJtZXJjaGFudF9hZG1pbiIsImNvbmZpZ3VyYXRpb24iLCJwYXltYXJrZCIsInNob3BwZXJfc2NpZW5jZSIsImx0cCIsImNhbXBhaWduX3RyYWNrIiwicmVzcG9uc3lzX2ZpbGVfcHJvY2Vzc29yIiwiZW1yIiwidHJhbnNhY3Rpb25zIiwibm90aWZ5IiwiY3JldyJdLCJzc29fdXNlcl9pZCI6ImQ2YTdlMGM4LTY2MWMtNDg0NS04OTRjLTRiMjhiZWZhMzc1ZiJ9.I4VlfRN9-_KSURmZnYCtQhPw6ZzEpKKNSIvMFCVvDQJPZiFWxjer1POVKJBU-z55krUeHSkZbrF5G1A9zGzZE5uBVxNjLRPQgyZhjk01zGTitwYFScXGsOFqVEmAMhjpjhCLP3v6gdVjqcRuwgyGbFaIuxFP32iq5x2Hvf9Ts6Zy_P1thk9ZB_JjuCZ0YRaTOOciM9b5MQsATUPiGzqUO-vbWr_opfQW_PNSotPd6NKt_J7DeZBJsD-gtkygDY3MCC3Nh2fVLGOSpeuY1BK8KkkYrCDi0pJLb1XLmH-nk2KiGOBEiRdQOIUdsRELrruYCfOiWP-zmP-kHiJjcbj0UA</cas:jwt>
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
      conn: conn, ok_xml: ok_xml, error_xml: error_xml
    }
  end

  test "redirect callback redirects to login url" do
    conn = conn(:get, "/login") |> CAS.handle_request!()

    assert conn.status == 302
  end

  test "login callback without service ticket shows an error" do
    conn = CAS.handle_callback!(%Plug.Conn{params: %{}})
    assert Map.has_key?(conn.assigns, :ueberauth_failure)
  end

  test "successful login callback validates the ticket", %{ok_xml: xml} do
    with_mock HTTPoison,
      get: fn _url, _opts, _params ->
        {:ok, %HTTPoison.Response{status_code: 200, body: xml, headers: []}}
      end do
      conn = CAS.handle_callback!(%Plug.Conn{params: %{"ticket" => "ST-XXXXX"}})

      assert conn.private.cas_ticket == "ST-XXXXX"
      assert conn.private.cas_user.user == "email@example.com"
    end
  end

  test "invalid login callback returns an error", %{error_xml: xml} do
    with_mock HTTPoison,
      get: fn _url, _opts, _params ->
        {:ok, %HTTPoison.Response{status_code: 200, body: xml, headers: []}}
      end do
      conn = CAS.handle_callback!(%Plug.Conn{params: %{"ticket" => "ST-XXXXX"}})

      assert List.first(conn.assigns.ueberauth_failure.errors).message == "INVALID_TICKET"
    end
  end

  test "cleanup callback", %{conn: conn} do
    conn = CAS.handle_cleanup!(conn)

    assert conn.private.cas_user == nil
    assert conn.private.cas_ticket == nil
  end

  test "use user email as uniqe uid", %{conn: conn} do
    uid = CAS.uid(conn)

    assert uid == "email@example.com"
  end

  test "generates info struct", %{conn: conn} do
    info = CAS.info(conn)

    assert info.email == "email@example.com"
  end

  test "generates credentials struct", %{conn: conn} do
    credentials = CAS.credentials(conn)

    assert credentials.expires == false
    assert credentials.token == "ST-XXXXX"
    # assert credentials.other == ["developer"]
  end

  test "generates extra struct", %{conn: conn} do
    extra = CAS.extra(conn)

    assert extra.raw_info == %{}
  end

  test "validates the JWT", %{conn: conn} do
    extra = CAS.extra(conn)

    assert extra.raw_info == %{}
  end
end
