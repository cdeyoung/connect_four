defmodule ConnectFour.Guards do
  @moduledoc """
  Custom guards for ConnectFour.
  """

  defguard valid_turn(column, player) when column >= 1 and column <= 7 and player in [:red, :yellow]
end
