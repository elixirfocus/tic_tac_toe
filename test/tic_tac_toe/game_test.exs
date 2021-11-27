defmodule TicTacToe.GameTest do
  # INFO: I prefer to always be explicit about async with this `use` call.
  use ExUnit.Case, async: true

  # Capturing IO during an async test on a larger project might be an issue, but
  # has not been an issue here.
  import ExUnit.CaptureIO

  doctest TicTacToe.Game

  alias TicTacToe.Game

  @valid_positions [
    :position_0,
    :position_1,
    :position_2,
    :position_3,
    :position_4,
    :position_5,
    :position_6,
    :position_7,
    :position_8
  ]

  describe "new/2" do
    test "success: creates a game with am empty board and expected next_turn" do
      assert %Game{} = Game.new()
    end
  end

  describe "next_turn/2" do
    test "success: returns expected first turn for new game" do
      assert Game.next_turn(Game.new()) == :x_player
    end

    test "success: returns :game_over when there are no more moves to play" do
      assert Game.next_turn(tie_game()) == :game_over
    end
  end

  describe "position_value/2" do
    test "success: returns a full empty board for a new game" do
      game = Game.new()

      for position <- @valid_positions do
        assert Game.position_value(game, position) == :empty
      end
    end

    test "failure: returns expected error if asking for a value at invalid position" do
      assert Game.position_value(Game.new(), :position_9) == {:error, :invalid_position}
    end
  end

  describe "play_turn/2" do
    test "success: given a new game the X player can record a turn and change the board" do
      game =
        Game.new()
        |> Game.play_turn(:position_4, :x)

      assert Game.next_turn(game) == :o_player
      assert Game.position_value(game, :position_4) == :x
    end

    test "failure: given a new game, if the O player attempts to play a turn it is not accepted" do
      assert {:error, :unplayable_turn} = Game.play_turn(Game.new(), :position_4, :o)
    end

    test "failure: given a new game, and after the X player has recorded a turn, the O player can not play a turn of the same position" do
      game =
        Game.new()
        |> Game.play_turn(:position_4, :x)

      assert {:error, :unplayable_turn} = Game.play_turn(game, :position_4, :o)
    end
  end

  describe "winner/2" do
    test "success: when given a complete game, will return the winning player" do
      game =
        Game.new()
        |> Game.play_turn(:position_0, :x)
        |> Game.play_turn(:position_3, :o)
        |> Game.play_turn(:position_1, :x)
        |> Game.play_turn(:position_4, :o)
        |> Game.play_turn(:position_2, :x)

      assert Game.winner?(game) == :x_player
    end

    test "success: when given an incomplete game, will return `:game_in_progress" do
      assert Game.winner?(Game.new()) == :game_in_progress
    end

    test "success: when given a complete game with no winner will return `:tie_game`" do
      assert Game.winner?(tie_game()) == :tie_game
    end
  end

  describe "draw/1" do
    test "success: when given a game (X winner) will output a visual representation of it to the console" do
      output =
        capture_io(fn ->
          Game.new()
          |> Game.play_turn(:position_0, :x)
          |> Game.play_turn(:position_3, :o)
          |> Game.play_turn(:position_1, :x)
          |> Game.play_turn(:position_4, :o)
          |> Game.play_turn(:position_2, :x)
          |> Game.draw()
        end)

      assert output == """
              X | X | X
             ———————————
              O | O |\s\s
             ———————————
                |   |\s\s

             Winner: X!
             """
    end

    test "success: when given a game (O winner) will output a visual representation of it to the console" do
      output =
        capture_io(fn ->
          Game.new()
          |> Game.play_turn(:position_0, :x)
          |> Game.play_turn(:position_2, :o)
          |> Game.play_turn(:position_1, :x)
          |> Game.play_turn(:position_4, :o)
          |> Game.play_turn(:position_3, :x)
          |> Game.play_turn(:position_6, :o)
          |> Game.draw()
        end)

      assert output == """
              X | X | O
             ———————————
              X | O |\s\s
             ———————————
              O |   |\s\s

             Winner: O!
             """
    end

    test "success: when given a game (tie) will output a visual representation of it to the console" do
      output =
        capture_io(fn ->
          Game.new()
          |> Game.play_turn(:position_4, :x)
          |> Game.play_turn(:position_0, :o)
          |> Game.play_turn(:position_3, :x)
          |> Game.play_turn(:position_5, :o)
          |> Game.play_turn(:position_2, :x)
          |> Game.play_turn(:position_6, :o)
          |> Game.play_turn(:position_7, :x)
          |> Game.play_turn(:position_1, :o)
          |> Game.play_turn(:position_8, :x)
          |> Game.draw()
        end)

      assert output == """
              O | O | X
             ———————————
              X | X | O
             ———————————
              O | X | X

             Tie Game.
             """
    end

    test "success: when given a in-progress game will output a visual representation of it to the console" do
      output =
        capture_io(fn ->
          Game.new()
          |> Game.play_turn(:position_4, :x)
          |> Game.draw()
        end)

      assert output == """
                |   |\s\s
             ———————————
                | X |\s\s
             ———————————
                |   |\s\s

             Game in progress.
             """
    end
  end

  defp tie_game() do
    # x | o | x
    # x | o | o
    # o | x | x

    Game.new()
    |> Game.play_turn(:position_0, :x)
    |> Game.play_turn(:position_1, :o)
    |> Game.play_turn(:position_2, :x)
    |> Game.play_turn(:position_4, :o)
    |> Game.play_turn(:position_3, :x)
    |> Game.play_turn(:position_5, :o)
    |> Game.play_turn(:position_7, :x)
    |> Game.play_turn(:position_6, :o)
    |> Game.play_turn(:position_8, :x)
  end
end
