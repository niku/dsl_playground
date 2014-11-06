defmodule DslPlayground do
  defmacro first_dsl(expr) do
    # expr =>
    # [do: {:__block__, [line: 5],
    #   [{:hoge, [line: 7], [1]}, {:fuga, [line: 8], [2]}]}]

    {:__block__, _, val} = Keyword.get(expr, :do)
    # val =>
    # [{:hoge, [line: 7], [1]}, {:fuga, [line: 8], [2]}]

    result =  Enum.reduce(val, %{}, fn(x, acc) -> {key, _, [val]} = x; Dict.put(acc, key, val) end)
    # result =>
    # %{fuga: 2, hoge: 1}

    quote do: %{hoge: 1, fuga: 2}
  end
end
