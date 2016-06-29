defmodule Ueberauth.Strategy.CAS.User.Test do
  use ExUnit.Case

  alias Ueberauth.Strategy.CAS.User

  setup do
    xml = """
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

    {:ok, xml: xml}
  end

  test "generates user from xml", %{xml: xml} do
    user = User.from_xml(xml)

    assert user.email == "mail@marceldegraaf.net"
    assert user.roles == ["developer", "admin"]
    assert user.name == user.email
  end
end
