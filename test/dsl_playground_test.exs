defmodule DslPlaygroundTest do
  use ExUnit.Case
  import DslPlayground

  test "first_dsl" do
    result = first_dsl do
      hoge 1
      fuga 2
    end
    assert result == %{hoge: 1, fuga: 2}
  end
end
