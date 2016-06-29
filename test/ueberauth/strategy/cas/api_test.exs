defmodule Ueberauth.Strategy.CAS.API.Test do
  use ExUnit.Case

  alias Ueberauth.Strategy.CAS.API

  test "generates a cas login url" do
    assert API.login_url == "http://cas.example.com/login"
  end
end
