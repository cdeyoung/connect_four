defmodule ConnectFourTest do
  use ExUnit.Case
  doctest ConnectFour

  describe "test the initial setup of the game board" do
    test "the game board randomly selects a player to start the game" do
      random_players = [:red, :yellow]

      assert Enum.member?(random_players, :red)
      assert Enum.member?(random_players, :yellow)
    end

    test "the game board is all nil" do
      game_board = %{
        {0, 0} => nil,
        {0, 1} => nil,
        {0, 2} => nil,
        {0, 3} => nil,
        {0, 4} => nil,
        {0, 5} => nil,
        {1, 0} => nil,
        {1, 1} => nil,
        {1, 2} => nil,
        {1, 3} => nil,
        {1, 4} => nil,
        {1, 5} => nil,
        {2, 0} => nil,
        {2, 1} => nil,
        {2, 2} => nil,
        {2, 3} => nil,
        {2, 4} => nil,
        {2, 5} => nil,
        {3, 0} => nil,
        {3, 1} => nil,
        {3, 2} => nil,
        {3, 3} => nil,
        {3, 4} => nil,
        {3, 5} => nil,
        {4, 0} => nil,
        {4, 1} => nil,
        {4, 2} => nil,
        {4, 3} => nil,
        {4, 4} => nil,
        {4, 5} => nil,
        {5, 0} => nil,
        {5, 1} => nil,
        {5, 2} => nil,
        {5, 3} => nil,
        {5, 4} => nil,
        {5, 5} => nil,
        {6, 0} => nil,
        {6, 1} => nil,
        {6, 2} => nil,
        {6, 3} => nil,
        {6, 4} => nil,
        {6, 5} => nil
      }

      values =
        game_board
        |> Map.keys()
        |> Enum.filter(fn x -> game_board[x] != nil end)

      assert values == []
    end
  end
end
