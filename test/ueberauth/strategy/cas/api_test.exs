defmodule Ueberauth.Strategy.CAS.API.Test do
  use ExUnit.Case
  import Mock

  alias Ueberauth.Strategy.CAS.API

  test "validates a valid ticket response" do
    ok_xml = """
    <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
      <cas:authenticationSuccess>
        <cas:user>mail@marceldegraaf.net</cas:user>
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

    with_mock HTTPoison,
      get: fn _url, _opts, _params ->
        {:ok, %HTTPoison.Response{status_code: 200, body: ok_xml, headers: []}}
      end do
      {:ok, %Ueberauth.Strategy.CAS.User{name: name}} =
        API.validate_ticket("ST-XXXXX", "http://cas.example.com/serviceValidate", "service_name")

      assert name == "mail@marceldegraaf.net"
    end
  end

  test "validates an invalid ticket response" do
    error_xml = """
    <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
      <cas:authenticationFailure code="INVALID_TICKET">Ticket 'ST-XXXXX' already consumed</cas:authenticationFailure>
    </cas:serviceResponse>
    """

    with_mock HTTPoison,
      get: fn _url, _opts, _params ->
        {:ok, %HTTPoison.Response{status_code: 200, body: error_xml, headers: []}}
      end do
      {:error, {code, message}} =
        API.validate_ticket("ST-XXXXX", "http://cas.example.com/serviceValidate", "service_name")

      assert code == "INVALID_TICKET"
      assert message == "Ticket 'ST-XXXXX' already consumed"
    end
  end

  test "validates an unknown error code ticket response" do
    unknown_error_xml = """
    <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
      <cas:authenticationFailure>An unknown error occurred</cas:authenticationFailure>
    </cas:serviceResponse>
    """

    with_mock HTTPoison,
      get: fn _url, _opts, _params ->
        {:ok, %HTTPoison.Response{status_code: 200, body: unknown_error_xml, headers: []}}
      end do
      {:error, {code, message}} =
        API.validate_ticket("ST-XXXXX", "http://cas.example.com/serviceValidate", "service_name")

      assert code == "unknown_error"
      assert message == "An unknown error occurred"
    end
  end

  test "validates an unknown error message ticket response" do
    unknown_error_xml = """
    <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
      <cas:authenticationFailure code='CONNECTION_ERROR'></cas:authenticationFailure>
    </cas:serviceResponse>
    """

    with_mock HTTPoison,
      get: fn _url, _opts, _params ->
        {:ok, %HTTPoison.Response{status_code: 200, body: unknown_error_xml, headers: []}}
      end do
      {:error, {code, message}} =
        API.validate_ticket("ST-XXXXX", "http://cas.example.com/serviceValidate", "service_name")

      assert code == "CONNECTION_ERROR"
      assert message == "Unknown error"
    end
  end

  test "validates an unknown error code and message ticket response" do
    unknown_error_xml = """
    <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
      <cas:authenticationFailure/>
    </cas:serviceResponse>
    """

    with_mock HTTPoison,
      get: fn _url, _opts, _params ->
        {:ok, %HTTPoison.Response{status_code: 200, body: unknown_error_xml, headers: []}}
      end do
      {:error, {code, message}} =
        API.validate_ticket("ST-XXXXX", "http://cas.example.com/serviceValidate", "service_name")

      assert code == "unknown_error"
      assert message == "Unknown error"
    end
  end

  test "validates garbage response" do
    with_mock HTTPoison,
      get: fn _url, _opts, _params ->
        {:ok, %HTTPoison.Response{status_code: 200, body: "blip blob", headers: []}}
      end do
      {:error, {code, _}} =
        API.validate_ticket("ST-XXXXX", "http://cas.example.com/serviceValidate", "service_name")

      assert code == "malformed_xml"
    end
  end
end
