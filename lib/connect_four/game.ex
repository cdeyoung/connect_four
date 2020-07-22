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
  Set the player's turn. ONLY USE FOR TESTING!
  """
  def players_turn(player) do
    GenServer.call(__MODULE__, {:players_turn, player})
  end

  @doc """
  Start/restart the game.
  """
  def reset do
    GenServer.cast(__MODULE__, :reset)
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
    column
    |> best_move()
    |> case do
      :out_of_bounds ->
        :out_of_bounds

      position ->
        position
        |> _take_a_turn(player)
        |> case do
          true ->
            :winner

          false ->
            GenServer.call(__MODULE__, :next_player)
            if GenServer.call(__MODULE__, :any_open) do
              :loser
            else
              :stalemate
            end
        end
    end
  end

  @doc """
  Whose turn is it?
  """
  def whose_turn do
    GenServer.call(__MODULE__, :whose_turn)
  end

  def best_move(column) do
    GenServer.call(__MODULE__, {:best_move, column})
  end

  ################################################################################
  # Server Callbacks.
  ################################################################################

  @impl GenServer
  def init(state) do
    state = Map.put(state, :board, _generate_board())

    {:ok, state}
  end

  @impl GenServer
  def handle_call(:any_open, _from, state) do
    all_nils = state.board
    |> Map.keys()
    |> Enum.filter(fn(x) ->
      state.board[x] == nil
    end)

    {:reply, all_nils != [], state}
  end

  @impl GenServer
  def handle_call({:best_move, column}, _from, state) do
    list_length = 5
    best_move = Enum.find_index(list_length..0, fn x ->
      state.board["#{inspect {x, column}}"] == nil
    end)

    case best_move do
      nil ->
        {:reply, :out_of_bounds, state}

      _ ->
        {:reply, {list_length - best_move, column}, state}
    end
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
  def handle_call({:players_turn, player}, _from, state) do
    {:reply, :ok, %{ state | player: player }}
  end

  @impl GenServer
  def handle_call({:take_turn, player, position}, _from, state) do
    Piece.start_link(%{player: player, position: position})
    state = put_in(state, [:board, "#{inspect position}"], {:global, "#{inspect position}"})

    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_call(:whose_turn, _from, state) do
    {:reply, state.player, state}
  end

  @impl GenServer
  def handle_cast(:reset, state) do
    state.board
    |> Map.keys()
    |> Enum.filter(fn x -> state.board[x] != nil end)
    |> Enum.each(fn x -> GenServer.cast({:global, x}, :stop) end)

    {:noreply, %{ state | board: _generate_board(), player: _randomize_player()}}
  end

  ################################################################################
  # Private Functions.
  ################################################################################

  defp _generate_board do
    for row <- 0..5,
      column <- 0..6,
      reduce: %{} do
        acc -> Map.put(acc, "#{inspect {row, column}}", nil)
      end
  end

  defp _randomize_player do
    Enum.random(~w(red yellow)a)
  end

  defp _take_a_turn(position, player) do
    {:global, "#{inspect position}"}
    |> GenServer.whereis()
    |> case do
      nil ->
        GenServer.call(__MODULE__, {:take_turn, player, position})
        |> case do
          :ok ->
            GenServer.call({:global, "#{inspect position}"}, :take_turn)

          :out_of_bounds ->
            :out_of_bounds
        end

      _ ->
        GenServer.call({:global, "#{inspect position}"}, :take_turn)
    end
  end
end
