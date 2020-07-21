defmodule ConnectFour.Piece do
  @moduledoc """
  GenServer for managing each piece of the game.
  """
  use GenServer

  ################################################################################
  # Client API.
  ################################################################################

  @doc """
  Start the ConnectFour.Game server with the specified parameters.
  """
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  ################################################################################
  # Server Callbacks.
  ################################################################################

  @impl GenServer
  def init(state) do
    state = Map.put(state, :is_winner, _won?(state.position))

    GenServer.call(__MODULE__, :check_for_win)
    {:ok, state}
  end

  @impl GenServer
  def handle_call(:player, _from, state) do
    {:reply, state.player, state}
  end

  ################################################################################
  # Private Functions.
  ################################################################################

  defp _four_in_a_row?([{_, _,}, {_, _}, {_, _}, {_, _}]), do: true

  defp _four_in_a_row?([_, {_, _,}, {_, _}, {_, _}, {_, _}]), do: true

  defp _four_in_a_row?([{_, _,}, {_, _}, {_, _}, {_, _}, _]), do: true

  defp _four_in_a_row?([{_, _,}, {_, _}, {_, _}, {_, _}, _, _]), do: true

  defp _four_in_a_row?([_, _, {_, _,}, {_, _}, {_, _}, {_, _}]), do: true

  defp _four_in_a_row?(_), do: false

  defp _line_check?(line) do
    if length(line) < 4 do
      false
    else
      line
      |> Enum.reduce([], fn(pos, acc) ->
        {:global, "#{inspect pos}"}
        |> GenServer.whereis()
        |> case do
          nil ->
            [ nil | acc ]

          _ ->
            [ GenServer.call({:global, "#{inspect pos}"}, :player) | acc ]
        end
      end)
      |> Enum.sort()
      |> _four_in_a_row?()
    end
  end

  defp _won?(position) do
    surrounding = _surrounding_positions(position)
    IO.inspect(surrounding)

    _line_check?(surrounding.row_positions) or
    _line_check?(surrounding.column_positions) or
    _line_check?(surrounding.diagonal_down_positions) or
    _line_check?(surrounding.diagonal_up_positions)
  end

  defp _surrounding_positions({row, column}) do
    x_beginning = if (row - 3 >= 0), do: row - 3, else: 0
    x_end = if (row + 3 <= 6), do: row + 3, else: 6
    y_beginning = if (column - 3 >= 0), do: column - 3, else: 0
    y_end = if (column + 3 <= 5), do: column + 3, else: 5
    diagonal_up_beginning = 6 - row

    %{
      row_positions: Enum.reduce(x_beginning..x_end, [], fn(x, acc) -> [ {x, row} | acc ] end) |> Enum.sort(),
      column_positions: Enum.reduce(y_beginning..y_end, [], fn(y, acc) -> [ {column, y} | acc ] end) |> Enum.sort(),
      diagonal_down_positions: Enum.zip(x_beginning..x_end, y_beginning..y_end),
      diagonal_up_positions: Enum.zip(diagonal_up_beginning..x_end, y_end..y_beginning)
    }
  end
end
