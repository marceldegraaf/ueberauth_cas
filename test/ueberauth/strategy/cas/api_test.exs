defmodule Ueberauth.Strategy.CAS.API.Test do
  use ExUnit.Case

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

    {:ok, ok_xml: ok_xml, error_xml: error_xml}
  end

  test "generates a cas login url" do
    assert API.login_url == "http://cas.example.com/login"
  end

  test "validates a successful ticket response", %{ok_xml: ok_xml} do
  end

  test "validates a failed ticket response", %{error_xml: error_xml} do
  end
end
