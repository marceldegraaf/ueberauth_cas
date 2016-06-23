defmodule Ueberauth.Strategy.CAS.ValidateTicketResponse do
  @moduledoc """
  Response to a serviceValidate request.
  """

  defstruct status_code: 0, user: nil
end
