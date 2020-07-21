defmodule ConnectFour.Guards do
  @moduledoc """
  Custom guards for ConnectFour.
  """

  defguard valid_turn(column, player) when column >= 0 and column <= 6 and player in [:red, :yellow]
end
