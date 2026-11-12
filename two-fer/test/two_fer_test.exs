defmodule TwoFerTest do
  use ExUnit.Case

  test "no name given" do
    assert TwoFer.two_fer() == "One for you, one for me."
  end

  test "a name given" do
    assert TwoFer.two_fer("Alice") == "One for Alice, one for me."
  end

  test "another name given" do
    assert TwoFer.two_fer("Bob") == "One for Bob, one for me."
  end
end
