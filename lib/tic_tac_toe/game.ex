defmodule TicTacToe.Game do
  @moduledoc """
  A data structure that holds the state related to a traditional 3x3 grid game
  of Tic-Tac-Toe.
  """

  # INFO: I prefer to alias this here so later in the typespec and other pattern
  # matching I can refer to the type / module `Game` instead of `__MODULE__`.
  alias TicTacToe.Game

  @typedoc "A set of valid values for a single position within the board."
  @type position_value :: :empty | :x | :o

  @typedoc "A set of known names for positions within the board."
  @type position_name ::
          :position_0
          | :position_1
          | :position_2
          | :position_3
          | :position_4
          | :position_5
          | :position_6
          | :position_7
          | :position_8

  @typedoc "A set of values to represent the next player allowed to make a turn or game over."
  @type next_turn_value :: :x_player | :o_player | :game_over

  # INFO: For scope/simplicity reasons I will only be storing the current state
  # of the board.  I do think it would be interesting to store the full historic
  # move list and render the board from it but not going to do that now.

  @typedoc "A typespec for the `TicTacToe.Game` struct."
  @type t :: %Game{
          board: %{
            position_0: position_value,
            position_1: position_value,
            position_2: position_value,
            position_3: position_value,
            position_4: position_value,
            position_5: position_value,
            position_6: position_value,
            position_7: position_value,
            position_8: position_value
          },
          next_turn: next_turn_value
        }

  @enforce_keys [:board, :next_turn]
  defstruct [:board, :next_turn]

  @doc "Returns a new game with an empty board."
  @spec new :: TicTacToe.Game.t()
  def new() do
    %__MODULE__{
      board: %{
        position_0: :empty,
        position_1: :empty,
        position_2: :empty,
        position_3: :empty,
        position_4: :empty,
        position_5: :empty,
        position_6: :empty,
        position_7: :empty,
        position_8: :empty
      },
      next_turn: :x_player
    }
  end

  # INFO: We want to provide an explicit interface and not leak the
  # implementation. In a first pass, we might have historically expected users
  # of this structure to peek into it and find things like `next_turn`, but by
  # having an interface would can evolve the app to have more than 2 players or
  # a different sized board.

  @doc """
  Returns the next player turn for the given game.

  Returns either `:x_player` or `:o_player` for a game in-progress.

  Returns `:game_over` if there are no more turns to be made.

  ## Examples

      iex> TicTacToe.Game.next_turn(TicTacToe.Game.new())
      :x_player

  """
  @spec next_turn(Game.t()) :: next_turn_value
  def next_turn(%Game{next_turn: value}), do: value

  # INFO: In the docs I refer to "game" but if this was an external module I
  # would prefer to refer to `TicTacToe.Game` so as to make it linkable in the
  # rendered ex_doc output.

  @doc """
  Returns the position value for the given game and requested position.

  Returns `{:error, :invalid_position}` if the given position is unknown.

  ## Examples

      iex> TicTacToe.Game.position_value(TicTacToe.Game.new(), :position_3)
      :empty

      iex> TicTacToe.Game.position_value(TicTacToe.Game.new(), :position_foobar)
      {:error, :invalid_position}

  """
  @spec position_value(Game.t(), position_name) :: position_value | {:error, :invalid_position}
  def position_value(%Game{board: board}, position) do
    Map.get(board, position, {:error, :invalid_position})
  end

  @doc """
  Returns an updated game, recording the given turn within the board.

  If the turn was invalid or if the game was done, returns `{:error, :unplayable_turn}`.
  """
  @spec play_turn(Game.t(), position_name(), position_value()) ::
          Game.t() | {:error, :unplayable_turn}
  def play_turn(%Game{} = game, position, value) do
    with :game_in_progress <- winner?(game),
         :empty <- position_value(game, position),
         true <- allowed_turn?(game, value) do
      game
      |> update_board(position, value)
      |> cycle_next_turn()
    else
      _ -> {:error, :unplayable_turn}
    end
  end

  @doc """
  Returns the winner of a given game.

  Returned values can be:

  * `:game_in_progress`
  * `:o_player`
  * `:x_player`
  * `:tie_game`
  """
  @spec winner?(Game.t()) :: :game_in_progress | :o_player | :x_player | :tie_game
  def winner?(game) do
    cond do
      check_win(game, :x) == true ->
        :x_player

      check_win(game, :o) == true ->
        :o_player

      check_tie(game) == true ->
        :tie_game

      true ->
        :game_in_progress
    end
  end

  @doc """
  Outputs an ascii representation of the game state.

  ## Sample:

    ```text
     O | O | X
    ———————————
     X | X | O
    ———————————
     O | X | X

    Tie Game.
    ```
  """
  @spec draw(Game.t()) :: Game.t()
  def draw(game) do
    ascii_board = """
     #{game.board.position_0} | #{game.board.position_1} | #{game.board.position_2}
    ———————————
     #{game.board.position_3} | #{game.board.position_4} | #{game.board.position_5}
    ———————————
     #{game.board.position_6} | #{game.board.position_7} | #{game.board.position_8}
    """

    ascii_board
    |> String.replace("x", "X")
    |> String.replace("o", "O")
    |> String.replace("empty", " ")
    |> IO.write()

    IO.write("\n")

    case winner?(game) do
      :game_in_progress ->
        IO.puts("Game in progress.")

      :o_player ->
        IO.puts("Winner: O!")

      :x_player ->
        IO.puts("Winner: X!")

      :tie_game ->
        IO.puts("Tie Game.")
    end

    game
  end

  defp check_win(%Game{} = game, value) do
    has_horizontal_win?(game, value) ||
      has_vertical_win?(game, value) ||
      has_cross_win?(game, value)
  end

  defp check_tie(%Game{board: board}) do
    :empty not in Map.values(board)
  end

  defp has_horizontal_win?(%Game{board: board}, value) when value in [:x, :o] do
    case board do
      %{position_0: ^value, position_1: ^value, position_2: ^value} -> true
      %{position_3: ^value, position_4: ^value, position_5: ^value} -> true
      %{position_6: ^value, position_7: ^value, position_8: ^value} -> true
      _ -> false
    end
  end

  defp has_vertical_win?(%Game{board: board}, value) when value in [:x, :o] do
    case board do
      %{position_0: ^value, position_3: ^value, position_6: ^value} -> true
      %{position_1: ^value, position_4: ^value, position_7: ^value} -> true
      %{position_2: ^value, position_5: ^value, position_8: ^value} -> true
      _ -> false
    end
  end

  defp has_cross_win?(%Game{board: board}, value) when value in [:x, :o] do
    case board do
      %{position_0: ^value, position_4: ^value, position_8: ^value} -> true
      %{position_2: ^value, position_4: ^value, position_6: ^value} -> true
      _ -> false
    end
  end

  defp allowed_turn?(%Game{next_turn: :x_player}, :x), do: true
  defp allowed_turn?(%Game{next_turn: :o_player}, :o), do: true
  defp allowed_turn?(_, _), do: false

  defp update_board(%Game{board: board} = game, position, value) do
    new_board = put_in(board[position], value)
    %{game | board: new_board}
  end

  defp cycle_next_turn(%Game{next_turn: current_turn} = game) do
    case {winner?(game), current_turn} do
      {:game_in_progress, :x_player} ->
        %{game | next_turn: :o_player}

      {:game_in_progress, :o_player} ->
        %{game | next_turn: :x_player}

      {_, _} ->
        %{game | next_turn: :game_over}
    end
  end
end
