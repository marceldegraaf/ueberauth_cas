defmodule Ueberauth.Strategy.CAS.API.Test do
  use ExUnit.Case
  import Mock

  alias Ueberauth.Strategy.CAS.API

  setup do
    ok_xml = """
    <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
      <cas:authenticationSuccess>
        <cas:user>Mail@marceldegraaf.net</cas:user>
        <cas:attributes>
          <cas:authenticationDate>2016-06-29T21:53:41Z</cas:authenticationDate>
          <cas:longTermAuthenticationRequestTokenUsed>false</cas:longTermAuthenticationRequestTokenUsed>
          <cas:isFromNewLogin>true</cas:isFromNewLogin>
          <cas:roles>
            <![CDATA[---
    - developer
    - admin
    ]]>
          </cas:roles>
        </cas:attributes>
      </cas:authenticationSuccess>
    </cas:serviceResponse>
    """

    error_xml = """
    <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
      <cas:authenticationFailure code="INVALID_TICKET">Ticket 'ST-XXXXX' already consumed</cas:authenticationFailure>
    </cas:serviceResponse>
    """

    unknown_error_xml = """
    <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
      <cas:authenticationFailure>An unknown error occurred</cas:authenticationFailure>
    </cas:serviceResponse>
    """

    {:ok, ok_xml: ok_xml, error_xml: error_xml, unknown_error_xml: unknown_error_xml}
  end

  test "generates a cas login url" do
    assert API.login_url == "http://cas.example.com/login"
  end

  test "validates an invalid ticket response", %{error_xml: error_xml} do
    with_mock HTTPoison, [
      get: fn(_url, _opts, _params) ->
        {:ok, %HTTPoison.Response{status_code: 200, body: error_xml, headers: []}
      } end
    ] do
      {:error, message} = API.validate_ticket("ST-XXXXX", %Plug.Conn{})

      assert message == "INVALID_TICKET"
    end
  end

  test "validates an unkonwn error ticket response", %{unknown_error_xml: unknown_error_xml} do
    with_mock HTTPoison, [
      get: fn(_url, _opts, _params) ->
        {:ok, %HTTPoison.Response{status_code: 200, body: unknown_error_xml, headers: []}
      } end
    ] do
      {:error, message} = API.validate_ticket("ST-XXXXX", %Plug.Conn{})

      assert message == "UNKNOWN_ERROR"
    end
  end
end
