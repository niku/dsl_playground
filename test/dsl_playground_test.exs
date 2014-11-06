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

  test "second_dsl" do
    result = second_dsl do
      hoge 1
      moge do
        fuga 2
      end
    end
    assert result == %{hoge: 1, moge: %{fuga: 2}}
  end

  test "build_map" do
    ast = [{:hoge, [line: 15], [1]},
           {:moge, [line: 16], [[do: {:fuga, [line: 17], [2]}]]}]
    assert build_map(ast) == %{hoge: 1, moge: %{fuga: 2}}
  end
end
