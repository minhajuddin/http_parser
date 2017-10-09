defmodule HttpParserTest do
  use ExUnit.Case
  doctest HttpParser

  test "greets the world" do
    assert HttpParser.hello() == :world
  end
end
