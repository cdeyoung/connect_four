defmodule ConnectFour do
  @moduledoc """
  Documentation for `ConnectFour`.
  """
  import ConnectFour.Guards
  alias ConnectFour.Game

  @doc """
  Get the current board.
  """
  def board do
    Game.board()
  end

  @doc """
  Reset the Connect Four game.
  """
  def reset do
    Game.reset()
  end

  @doc """
  Take a turn.
  """
  def take_turn(column, player) when valid_turn(column, player) do
    if whose_turn() == player do
      Game.take_turn(column, player)
    else
      IO.puts("This would have been a superlative choice if it were actually your turn.")
      :not_your_turn
    end
  end

  def take_turn(_column, _player) do
    IO.puts("You just dropped your piece on the floor. Try aiming for the board next time.")
    :not_your_turn
  end

  @doc """
  Get the current player.
  """
  def whose_turn do
    Game.whose_turn()
  end
end
