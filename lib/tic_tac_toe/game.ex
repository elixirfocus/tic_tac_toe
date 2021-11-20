defmodule TicTacToe.Game do
  @moduledoc """
  `TicTacToe.Game` is a data structure that holds the state related to a
  traditional 3x3 grid game of Tic-Tac-Toe.
  """

  @typedoc "The current value of a gird position."
  @type pos_value :: :empty | :x | :o

  @typedoc "The next player allowed to make a turn or game over."
  @type next_turn_value :: :x_player | :o_player | :game_over

  @typedoc """

  """
  @type t :: %__MODULE__{
          grid: %{
            pos_0: pos_value,
            pos_1: pos_value,
            pos_2: pos_value,
            pos_3: pos_value,
            pos_4: pos_value,
            pos_5: pos_value,
            pos_6: pos_value,
            pos_7: pos_value,
            pos_8: pos_value
          },
          next_turn: next_turn_value
        }

  @enforce_keys [:grid, :next_turn]
  defstruct [:grid, :next_turn]

  @spec new :: TicTacToe.Game.t()
  def new() do
    %__MODULE__{
      grid: %{
        pos_0: :empty,
        pos_1: :empty,
        pos_2: :empty,
        pos_3: :empty,
        pos_4: :empty,
        pos_5: :empty,
        pos_6: :empty,
        pos_7: :empty,
        pos_8: :empty
      },
      next_turn: :x_player
    }
  end
end
