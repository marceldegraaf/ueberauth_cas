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
          <cas:secondaryEmail>AnotherMail@marceldegraaf.net</cas:secondaryEmail>
          <cas:fullname>John Doe</cas:fullname>
          <cas:roles>
            <![CDATA[---
    - developer
    - admin
    - author
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

    assert user.name == "mail@marceldegraaf.net"
    assert user.email == "mail@marceldegraaf.net"
    assert user.roles == ["developer", "admin", "author"]
    assert user.attributes["fullname"] == "John Doe"
    assert user.attributes["secondary_email"] == "AnotherMail@marceldegraaf.net"
  end
end
