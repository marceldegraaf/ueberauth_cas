defmodule Ueberauth.Strategy.CAS.Logout.Test do
  use ExUnit.Case

  alias Ueberauth.Strategy.CAS.Logout

  setup do
    xml = """
      <samlp:LogoutRequest xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="42" Version="2.0" IssueInstant="2018-01-03 14:36:28 +0100">
        <saml:NameID>@NOT_USED@</saml:NameID>
        <samlp:SessionIndex>ST-XXXXX</samlp:SessionIndex>
      </samlp:LogoutRequest>
    """

    {:ok, xml: xml}
  end

  test "finds the ticket from the SAML request", %{xml: xml} do
    ticket = Logout.find_ticket(xml)
    assert ticket == "ST-XXXXX"
  end
end
