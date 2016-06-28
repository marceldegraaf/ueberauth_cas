defmodule Ueberauth.Strategy.CASTest do
  use ExUnit.Case

  alias Ueberauth.Strategy.CAS

  test "login callback without service ticket shows an error" do
    conn = CAS.handle_callback!(%Plug.Conn{params: %{}})
    assert Map.has_key?(conn.assigns, :ueberauth_failure)
  end

  test "login callback with a service ticket validates the ticket" do
    conn = CAS.handle_callback!(%Plug.Conn{params: %{"ticket" => "ST-XXXXX"}})

    assert conn.private.cas_ticket == "ST-XXXXX"
    assert conn.private.cas_user != nil
  end

  test "cleanup callback" do
    conn = CAS.handle_cleanup!(%Plug.Conn{private: %{cas_ticket: "ST-XXXXX", cas_user: "a user"}})

    assert conn.private.cas_user == nil
    assert conn.private.cas_ticket == nil
  end

  test "use user email as uniqe uid" do
    uid = CAS.uid(%Plug.Conn{private: %{cas_user: %CAS.User{name: "Marcel de Graaf", email: "mail@marceldegraaf.net"}}})

    assert uid == "mail@marceldegraaf.net"
  end
end
