defmodule Ueberauth.Strategy.CAS.Logout do
  @moduledoc """
  Read a logout request from a CAS Server (SAML protocol)
  """

  import SweetXml

  def find_ticket(body) do
    body |> xpath(~x"//samlp:LogoutRequest/samlp:SessionIndex/text()"s)
  end

end
