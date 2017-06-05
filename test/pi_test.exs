defmodule PiTest do
  use ExUnit.Case
  doctest Pi

  test "the truth" do
    assert 1 + 1 == 2
  end
end
