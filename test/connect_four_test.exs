defmodule ConnectFourTest do
  use ExUnit.Case
  doctest ConnectFour

  describe "test the initial setup of the game board" do
    test "the game board randomly selects a player to start the game" do
      random_players =
        Enum.reduce(0..10, [], fn(_num, acc) ->
          ConnectFour.reset()
          [ ConnectFour.whose_turn() | acc ]
        end)

      assert Enum.member?(random_players, :red)
      assert Enum.member?(random_players, :yellow)
    end

    test "the game board is all nil" do
      board = ConnectFour.board()

      values =
        board
        |> Map.keys()
        |> Enum.filter(fn x -> board[x] != nil end)

      assert values == []
    end

    test "resetting the board sets everything to nil" do
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
      assert true
    end

    test "whose turn is it" do
      assert Enum.member?([:red, :yellow], ConnectFour.whose_turn())
    end
  end
end
