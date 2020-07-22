defmodule ConnectFourTest do
  use ExUnit.Case
  doctest ConnectFour

  require Integer
  alias ConnectFour.Game

  @player_1 :red
  @player_2 :yellow

  describe "initial setup of the game board" do
    test "the game board randomly selects a player to start the game" do
      random_players =
        Enum.reduce(0..5, [], fn(_num, acc) ->
          ConnectFour.reset()
          [ ConnectFour.whose_turn() | acc ]
        end)

      assert Enum.member?(random_players, :red)
      assert Enum.member?(random_players, :yellow)
    end

    test "new game board is all nil" do
      ConnectFour.reset()
      board = ConnectFour.board()

      values =
        board
        |> Map.keys()
        |> Enum.filter(fn x -> board[x] != nil end)

      assert values == []
    end

    test "resetting the board sets everything to nil" do
      Game.players_turn(:red)
      ConnectFour.take_turn(2, :red)
      board = ConnectFour.board()

      values =
        board
        |> Map.keys()
        |> Enum.filter(fn x -> board[x] != nil end)

      assert values != []

      ConnectFour.reset()
      board = ConnectFour.board()

      values =
        board
        |> Map.keys()
        |> Enum.filter(fn x -> board[x] != nil end)

      assert values == []
    end
  end

  describe "test gameplay" do
    test "test the take turn function to make sure you cannot perform two moves in a row" do
      # Reset the board.
      ConnectFour.reset()

      # Player 1 takes a turn.
      Game.players_turn(@player_1)
      assert ConnectFour.whose_turn() == @player_1

      # It should now be player 2's turn.
      ConnectFour.take_turn(1, @player_1)
      assert ConnectFour.whose_turn() == @player_2

      # There should only be one entry in the board.
      board = ConnectFour.board()
      values =
        board
        |> Map.keys()
        |> Enum.filter(fn x -> board[x] != nil end)
      assert length(values) == 1

      # Player one takes a turn again, but gets denied.
      ConnectFour.take_turn(1, @player_1)
      board = ConnectFour.board()
      values =
        board
        |> Map.keys()
        |> Enum.filter(fn x -> board[x] != nil end)
      assert length(values) == 1
    end

    test "whose turn is it" do
      player = :red

      Game.players_turn(player)
      assert ConnectFour.whose_turn() == player
    end

    test "play a full game vertically" do
      ConnectFour.reset()
      Game.players_turn(@player_1)

      ConnectFour.take_turn(1, @player_1)
      ConnectFour.take_turn(2, @player_2)
      ConnectFour.take_turn(1, @player_1)
      ConnectFour.take_turn(2, @player_2)
      ConnectFour.take_turn(1, @player_1)
      ConnectFour.take_turn(2, @player_2)
      result = ConnectFour.take_turn(1, @player_1)

      assert result == :winner


    end

    test "play a full game horizontally." do
      ConnectFour.reset()
      Game.players_turn(@player_1)

      ConnectFour.take_turn(1, @player_1)
      ConnectFour.take_turn(2, @player_2)
      ConnectFour.take_turn(3, @player_1)
      ConnectFour.take_turn(1, @player_2)
      ConnectFour.take_turn(4, @player_1)
      ConnectFour.take_turn(3, @player_2)
      ConnectFour.take_turn(5, @player_1)
      ConnectFour.take_turn(1, @player_2)
      result = ConnectFour.take_turn(6, @player_1)

      assert result == :winner
    end

    test "play a full game diagonally down." do
      ConnectFour.reset()
      Game.players_turn(@player_1)

      ConnectFour.take_turn(1, @player_1)
      ConnectFour.take_turn(1, @player_2)
      ConnectFour.take_turn(1, @player_1)
      ConnectFour.take_turn(2, @player_2)
      ConnectFour.take_turn(1, @player_1)
      ConnectFour.take_turn(2, @player_2)
      ConnectFour.take_turn(2, @player_1)
      ConnectFour.take_turn(3, @player_2)
      ConnectFour.take_turn(3, @player_1)
      ConnectFour.take_turn(3, @player_2)
      result = ConnectFour.take_turn(4, @player_1)

      assert result == :winner
    end

    test "play a full game diagonally up." do
      ConnectFour.reset()
      Game.players_turn(@player_1)

      ConnectFour.take_turn(1, @player_1)
      ConnectFour.take_turn(2, @player_2)
      ConnectFour.take_turn(2, @player_1)
      ConnectFour.take_turn(3, @player_2)
      ConnectFour.take_turn(4, @player_1)
      ConnectFour.take_turn(3, @player_2)
      ConnectFour.take_turn(3, @player_1)
      ConnectFour.take_turn(4, @player_2)
      ConnectFour.take_turn(5, @player_1)
      ConnectFour.take_turn(4, @player_2)
      result = ConnectFour.take_turn(4, @player_1)

      assert result == :winner
    end

    test "stalemate" do
      ConnectFour.reset()
      Game.players_turn(@player_1)

      # Columns one and two.
      Enum.each(0..5, fn(x) ->
        if Integer.is_even(x) do
          ConnectFour.take_turn(1, @player_1)
          ConnectFour.take_turn(1, @player_2)
        else
          ConnectFour.take_turn(2, @player_1)
          ConnectFour.take_turn(2, @player_2)
        end
      end)

      # Columns three and four.
      Game.players_turn(@player_2)
      Enum.each(0..5, fn(x) ->
        if Integer.is_even(x) do
          ConnectFour.take_turn(3, @player_2)
          ConnectFour.take_turn(3, @player_1)
        else
          ConnectFour.take_turn(4, @player_2)
          ConnectFour.take_turn(4, @player_1)
        end
      end)

      # Columns five and six.
      Game.players_turn(@player_1)
      Enum.each(0..5, fn(x) ->
        if Integer.is_even(x) do
          ConnectFour.take_turn(5, @player_1)
          ConnectFour.take_turn(5, @player_2)
        else
          ConnectFour.take_turn(6, @player_1)
          ConnectFour.take_turn(6, @player_2)
        end
      end)

      # Column seven.
      Game.players_turn(@player_2)
      Enum.each(0..4, fn(x) ->
        if Integer.is_even(x) do
          ConnectFour.take_turn(7, @player_2)
        else
          ConnectFour.take_turn(7, @player_1)
        end
      end)

      result = ConnectFour.take_turn(7, @player_1)

      assert result == :stalemate
    end
  end
end
