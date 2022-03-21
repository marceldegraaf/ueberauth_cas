defmodule Ueberauth.Strategy.CAS.User.Test do
  use ExUnit.Case

  alias Ueberauth.Strategy.CAS.User

  test "response without custom attributes works" do
    xml = """
    <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
      <cas:authenticationSuccess>
        <cas:user>mail@marceldegraaf.net</cas:user>
      </cas:authenticationSuccess>
    </cas:serviceResponse>
    """

    user = User.from_xml(xml)

    assert user.name == "mail@marceldegraaf.net"
  end

  test "custom attributes are read" do
    response = """
    <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
      <cas:authenticationSuccess>
        <cas:user>username</cas:user>
        <cas:attributes>
          <cas:firstname>John</cas:firstname>
          <cas:lastname>Doe</cas:lastname>
          <cas:title>Mr.</cas:title>
          <cas:email>jdoe@example.org</cas:email>
          <cas:affiliation>staff</cas:affiliation>
          <cas:affiliation>faculty</cas:affiliation>
          <cas:numbers>1</cas:numbers>
          <cas:numbers>3</cas:numbers>
          <cas:numbers>2</cas:numbers>
        </cas:attributes>
        <cas:proxyGrantingTicket>PGTIOU-84678-8a9d...</cas:proxyGrantingTicket>
      </cas:authenticationSuccess>
    </cas:serviceResponse>
    """

    user = User.from_xml(response)

    assert user.name == "username"

    assert user.attributes == %{
             "firstname" => "John",
             "lastname" => "Doe",
             "title" => "Mr.",
             "email" => "jdoe@example.org",
             "affiliation" => ["staff", "faculty"],
             "numbers" => ["1", "3", "2"]
           }
  end

  test "attribute names are not modified when :sanitize_attribute_names option is false" do
    response = """
    <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
      <cas:authenticationSuccess>
        <cas:user>janedoe</cas:user>
        <cas:attributes>
          <cas:firstName>Jane</cas:firstName>
          <cas:last_name>Doe</cas:last_name>
          <cas:mail>jane.doe@mail.test</cas:mail>
          <cas:OtherMail>jane.doe@other.test</cas:OtherMail>
          <cas:Affiliation>staff</cas:Affiliation>
          <cas:Affiliation>faculty</cas:Affiliation>
          <cas:OTHER_ATTRIBUTE>123</cas:OTHER_ATTRIBUTE>
        </cas:attributes>
      </cas:authenticationSuccess>
    </cas:serviceResponse>
    """

    user = User.from_xml(response, sanitize_attribute_names: false)

    assert user.name == "janedoe"

    assert user.attributes == %{
             "firstName" => "Jane",
             "last_name" => "Doe",
             "mail" => "jane.doe@mail.test",
             "OtherMail" => "jane.doe@other.test",
             "Affiliation" => ["staff", "faculty"],
             "OTHER_ATTRIBUTE" => "123"
           }
  end
end
