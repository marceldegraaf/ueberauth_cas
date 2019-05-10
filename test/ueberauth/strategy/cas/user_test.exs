defmodule Ueberauth.Strategy.CAS.User.Test do
  use ExUnit.Case

  import ExUnit.CaptureLog
  require Logger
  import Mock
  alias Ueberauth.Strategy.CAS.User

  setup do
    xml = """
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

    {:ok, xml: xml}
  end

  test "generates user from xml", %{xml: xml} do
    user = User.from_xml(xml)

    assert user.user == "email@example.com"
    assert user.authentication_date == "2019-05-08T22:49:42Z"
    assert user.is_from_new_login == true
    assert user.long_term_authentication_request_token_used == false
    assert user.sso_user_id == "d6a7e0c8-661c-4845-894c-4b28befa375f"
  end

  test "JWT fails decoding, jwt_valid is false", %{xml: xml} do
    # Alter Header portion of the encoded JWT
    xml = String.replace(xml, "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzUxMiJ9", "X1X1X1X1X1X1X1X1X1X1X1X1")

    # Freeze time prior to when the JWT token expires
    with_mock Joken.CurrentTime.OS,
      current_time: fn -> 1_557_356_682 - 60 * 60 end do
      user = User.from_xml(xml)
      assert user.jwt_valid == false
      assert nil == user.jwt
    end
  end

  test "JWT fails decoding, capture a log msg", %{xml: xml} do
    # Alter Header portion of the encoded JWT
    xml = String.replace(xml, "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzUxMiJ9", "X1X1X1X1X1X1X1X1X1X1X1X1")

    assert capture_log(fn ->
             # Freeze time prior to when the JWT token expires
             with_mock Joken.CurrentTime.OS,
               current_time: fn -> 1_557_356_682 - 60 * 60 end do
               User.from_xml(xml)
             end
           end) =~ ~r/JWT token verify failed, reason: :signature_error/
  end

  test "JWT is decoded, passes claim validation, jwt_valid is true and jwt data is decoded", %{
    xml: xml
  } do
    # Freeze time prior to when the JWT token expires
    with_mock Joken.CurrentTime.OS,
      current_time: fn -> 1_557_356_682 - 60 * 60 end do
      user = User.from_xml(xml)
      assert called(Joken.CurrentTime.OS.current_time())
      assert user.jwt_valid == true

      assert %{
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
             } == user.jwt
    end
  end

  test "JWT is decoded, passes claim validation, log a msg", %{xml: xml} do
    assert capture_log(fn ->
             # Freeze time prior to when the JWT token expires
             with_mock Joken.CurrentTime.OS,
               current_time: fn -> 1_557_356_682 - 60 * 60 end do
               User.from_xml(xml)
             end
           end) =~ ~r/JWT ok/
  end

  test "JWT is decoded, fails claim validation, jwt_valid is false", %{xml: xml} do
    # Freeze time just after the JWT token has expired
    with_mock Joken.CurrentTime.OS,
      current_time: fn -> 1_557_356_682 + 1 end do
      user = User.from_xml(xml)

      assert called(Joken.CurrentTime.OS.current_time())
      assert user.jwt_valid == false
      assert nil == user.jwt
    end
  end

  test "JWT is decoded, fails claim validation, logs a msg", %{xml: xml} do
    assert capture_log(fn ->
             # Freeze time just after the JWT token has expired
             with_mock Joken.CurrentTime.OS,
               current_time: fn -> 1_557_356_682 + 1 end do
               User.from_xml(xml)
             end
           end) =~ ~r/Claim.*exp.* 1557356682.* did not pass validation/
  end

  test "JWT is decoded, passes claim validation, fails verification, jwt_valid is false", %{
    xml: xml
  } do
    # Alter Verification Signature portion of the encoded JWT
    xml = String.replace(xml, "JjuCZ0YRaTOOciM9b5MQsATUPiGzqUO-", "X1X1X1X1X1X1X1X1X1X1X1X1")
    # Freeze time prior to when the JWT token expires
    with_mock Joken.CurrentTime.OS,
      current_time: fn -> 1_557_356_682 - 60 * 60 end do
      user = User.from_xml(xml)

      assert user.jwt_valid == false
      assert nil == user.jwt
    end
  end

  test "JWT is decoded,  passes claim validation, fails verification, logs a msg", %{xml: xml} do
    # Alter Verification Signature portion of the encoded JWT
    xml = String.replace(xml, "JjuCZ0YRaTOOciM9b5MQsATUPiGzqUO-", "X1X1X1X1X1X1X1X1X1X1X1X1")

    assert capture_log(fn ->
             # Freeze time prior to when the JWT token expires
             with_mock Joken.CurrentTime.OS,
               current_time: fn -> 1_557_356_682 - 60 * 60 end do
               User.from_xml(xml)
             end
           end) =~ ~r/JWT token verify failed, reason: :signature_error/
  end
end
