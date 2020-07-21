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
end
