defmodule Ueberauth.Strategy.CAS.Test do
  use ExUnit.Case

  alias Ueberauth.Strategy.CAS

  setup do
    conn = %Plug.Conn{
      private: %{
        cas_user: %CAS.User{name: "Marcel de Graaf", email: "mail@marceldegraaf.net", roles: ["developer"]},
        cas_ticket: "ST-XXXXX",
      }
    }

    {:ok, conn: conn}
  end

  test "login callback without service ticket shows an error" do
    conn = CAS.handle_callback!(%Plug.Conn{params: %{}})
    assert Map.has_key?(conn.assigns, :ueberauth_failure)
  end

  test "login callback with a service ticket validates the ticket" do
    conn = CAS.handle_callback!(%Plug.Conn{params: %{"ticket" => "ST-XXXXX"}})

    assert conn.private.cas_ticket == "ST-XXXXX"
    assert conn.private.cas_user != nil
  end

  test "cleanup callback", %{conn: conn} do
    conn = CAS.handle_cleanup!(conn)

    assert conn.private.cas_user == nil
    assert conn.private.cas_ticket == nil
  end

  test "use user email as uniqe uid", %{conn: conn} do
    uid = CAS.uid(conn)

    assert uid == "mail@marceldegraaf.net"
  end

  test "generates info struct", %{conn: conn} do
    info = CAS.info(conn)

    assert info.name == "Marcel de Graaf"
    assert info.email == "mail@marceldegraaf.net"
  end

  test "generates credentials struct", %{conn: conn} do
    credentials = CAS.credentials(conn)

    assert credentials.expires == false
    assert credentials.token == "ST-XXXXX"
    assert credentials.other == ["developer"]
  end

  test "generates extra struct", %{conn: conn} do
    extra = CAS.extra(conn)

    assert extra.raw_info.user == conn.private.cas_user
  end
end
