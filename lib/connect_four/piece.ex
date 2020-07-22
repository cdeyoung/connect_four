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
  def start_link(%{position: position} = args) do
    GenServer.start_link(__MODULE__, args, name: {:global, "#{inspect position}"})
  end

  ################################################################################
  # Server Callbacks.
  ################################################################################

  @impl GenServer
  def init(state) do
    state = Map.put(state, :is_winner, _won?(state))

    {:ok, state}
  end

  @impl GenServer
  def handle_call(:take_turn, _from, state) do
    {:reply, state.is_winner, state}
  end

  @impl GenServer
  def handle_call(:player, _from, state) do
    {:reply, state.player, state}
  end

  @impl GenServer
  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  ################################################################################
  # Private Functions.
  ################################################################################

  defp _down_from_point(row, column), do: _down_from_point(row, column, 0, [{row, column}])

  defp _down_from_point(5, _column, _count, acc), do: acc

  defp _down_from_point(_row, 6, _count, acc), do: acc

  defp _down_from_point(_row, _column, count, acc) when count > 3, do: acc

  defp _down_from_point(row, column, count, acc) do
    row = row + 1
    column = column + 1
    _down_from_point(row, column, count + 1, [ {row, column} | acc ])
  end

  defp _down_to_point(row, column), do: _down_to_point(row, column, 0, [{row, column}])

  defp _down_to_point(0, _column, _count, acc), do: acc

  defp _down_to_point(_row, 0, _count, acc), do: acc

  defp _down_to_point(_row, _column, count, acc) when count > 3, do: acc

  defp _down_to_point(row, column, count, acc) do
    row = row - 1
    column = column - 1
    _down_to_point(row, column, count + 1, [ {row, column} | acc ])
  end

  defp _up_to_point(row, column), do: _up_to_point(row, column, 0, [{row, column}])

  defp _up_to_point(5, _column, _count, acc), do: acc

  defp _up_to_point(_row, 0, _count, acc), do: acc

  defp _up_to_point(_row, _column, count, acc) when count > 3, do: acc

  defp _up_to_point(row, column, count, acc) do
    row = row + 1
    column = column - 1
    _up_to_point(row, column, count + 1, [ {row, column} | acc ])
  end

  defp _up_from_point(row, column), do: _up_from_point(row, column, 0, [{row, column}])

  defp _up_from_point(0, _column, _count, acc), do: acc

  defp _up_from_point(_row, 6, _count, acc), do: acc

  defp _up_from_point(_row, _column, count, acc) when count > 3, do: acc

  defp _up_from_point(row, column, count, acc) do
    row = row - 1
    column = column + 1
    _up_from_point(row, column, count + 1, [ {row, column} | acc ])
  end
  defp _four_in_a_row?([:red, :red, :red, :red]), do: true

  defp _four_in_a_row?([:yellow, :yellow, :yellow, :yellow]), do: true

  defp _four_in_a_row?([_, :red, :red, :red, :red]), do: true

  defp _four_in_a_row?([_, :yellow, :yellow, :yellow, :yellow]), do: true

  defp _four_in_a_row?([:red, :red, :red, :red, _]), do: true

  defp _four_in_a_row?([:yellow, :yellow, :yellow, :yellow, _]), do: true

  defp _four_in_a_row?([:red, :red, :red, :red, _, _]), do: true

  defp _four_in_a_row?([:yellow, :yellow, :yellow, :yellow, _, _]), do: true

  defp _four_in_a_row?([_, _, :red, :red, :red, :red]), do: true

  defp _four_in_a_row?([_, _, :yellow, :yellow, :yellow, :yellow]), do: true

  defp _four_in_a_row?(_), do: false

  defp _line_check?(line, state) do
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
            if (state.position == pos) do
              [ state.player | acc ]
            else
              [ GenServer.call({:global, "#{inspect pos}"}, :player) | acc ]
            end
        end
      end)
      |> Enum.sort()
      |> _four_in_a_row?()
    end
  end

  defp _surrounding_positions({row, column}) do
    column_beginning = if (column - 3 >= 0), do: column - 3, else: 0
    column_end = if (column + 3 <= 6), do: column + 3, else: 6
    row_beginning = if (row - 3 >= 0), do: row - 3, else: 0
    row_end = if (row + 3 <= 5), do: row + 3, else: 5

    %{
      row_positions: Enum.reduce(column_beginning..column_end, [], fn(x, acc) -> [ {row, x} | acc ] end) |> Enum.sort(),
      column_positions: Enum.reduce(row_beginning..row_end, [], fn(y, acc) -> [ {y, column} | acc ] end) |> Enum.sort(),
      diagonal_down_positions: Enum.sort(_down_to_point(row, column) ++ _down_from_point(row, column)) |> MapSet.new() |> Enum.to_list(),
      diagonal_up_positions: Enum.sort(_up_to_point(row, column) ++ _up_from_point(row, column)) |> MapSet.new() |> Enum.to_list()
    }
  end

  defp _won?(state) do
    surrounding = _surrounding_positions(state.position)

    _line_check?(surrounding.row_positions, state) or
    _line_check?(surrounding.column_positions, state) or
    _line_check?(surrounding.diagonal_down_positions, state) or
    _line_check?(surrounding.diagonal_up_positions, state)
  end
end
