defmodule ExDjango.ZlibTest do
  use ExUnit.Case
  alias ExDjango.Zlib

  test "Zlib" do
    text = "test"
    result = Zlib.compress(text)
    assert Zlib.decompress(result) == text
  end

end
