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
    IO.puts("I've reset the game for you so you can lose some more, if you'd like.")
  end

  @doc """
  Take a turn.
  """
  def take_turn(column, player) when valid_turn(column, player) do
    if whose_turn() == player do
      Game.take_turn(column - 1, player)
      |> case do
        :loser ->
          IO.puts("DROPPED #{player} in #{column}.")
          :loser

        :out_of_bounds ->
          IO.puts("No, no. You just go ahead and keep on trying until you find an open column.")
          :out_of_bounds

        :stalemate ->
          IO.puts("Stalemate! Sigh...")
          :stalemate

        :winner ->
          IO.puts("#{player |> Atom.to_string() |> String.upcase()} won!")
          Game.reset()
          :winner
      end
    else
      IO.puts("This would have been a superlative choice if it were actually your turn.")
      :not_your_turn
    end
  end

  def take_turn(_column, _player) do
    IO.puts("You just dropped your piece on the floor, Butterthumbs. Try aiming for the board next time.")
    :butter_thumbs
  end

  @doc """
  Get the current player.
  """
  def whose_turn do
    Game.whose_turn()
  end
end
