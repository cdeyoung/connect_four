defmodule ConnectFour.Game do
  @moduledoc """
  GenServer for managing the Connect Four game board.
  """
  use GenServer

  alias ConnectFour.Piece

  ################################################################################
  # Client API.
  ################################################################################

  @doc """
  Get the current state of the game board.
  """
  def board do
    GenServer.call(__MODULE__, :board)
  end

  @doc """
  Start/restart the game.
  """
  def reset do
    GenServer.call(__MODULE__, :reset)
  end

  @doc """
  Start the ConnectFour.Game server with the specified parameters.
  """
  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{player: _randomize_player()}, name: __MODULE__)
  end

  @doc """
  Take a turn.
  """
  def take_turn(column, player) do
    position = {column, GenServer.call(__MODULE__, {:best_move, column})}

    {:global, "#{inspect position}"}
    |> GenServer.whereis()
    |> case do
      nil ->
        GenServer.call(__MODULE__, {:take_turn, position})
        GenServer.call({:global, "#{inspect position}"}, {:take_turn, %{position: position, player: player}})

      _ ->
        GenServer.call({:global, "#{inspect position}"}, {:take_turn, %{position: position, player: player}})
    end

    GenServer.call(__MODULE__, :next_player)
  end

  @doc """
  Whose turn is it?
  """
  def whose_turn do
    GenServer.call(__MODULE__, :whose_turn)
  end

  def best_move(column), do: GenServer.call(__MODULE__, {:best_move, column})

  ################################################################################
  # Server Callbacks.
  ################################################################################

  @impl GenServer
  def init(state) do
    state = Map.put(state, :board, _generate_board())

    {:ok, state}
  end

  @impl GenServer
  def handle_call({:best_move, column}, _from, state) do
    best_move = Enum.find_index(5..0, fn x ->
      state.board[{column, x}] == nil
    end)

    {:reply, best_move, state}
  end

  @impl GenServer
  def handle_call(:board, _from, state) do
    {:reply, state.board, state}
  end

  @impl GenServer
  def handle_call(:next_player, _from, state) do
    if state.player == :red do
      {:reply, :ok, %{ state | player: :yellow}}
    else
      {:reply, :ok, %{ state | player: :red}}
    end
  end

  @impl GenServer
  def handle_call(:reset, _from, _state) do
    state = %{
      player: _randomize_player(),
      board: _generate_board()
    }

    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_call({:take_turn, position}, _from, state) do
    Piece.start_link(position)
    state = Map.put(state, position, {:global, position})

    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_call(:whose_turn, _from, state) do
    {:reply, state.player, state}
  end

  ################################################################################
  # Private Functions.
  ################################################################################

  defp _generate_board do
    for row <- 0..6,
      column <- 0..5,
      reduce: %{} do
        acc -> Map.put(acc, {row, column}, nil)
      end
  end

  defp _randomize_player do
    Enum.random(~w(red yellow)a)
  end
end
