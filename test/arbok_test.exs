defmodule ArbokTest do
  use ExUnit.Case
  doctest Arbok

  test "greets the world" do
    assert Arbok.hello() == :world
  end
end
