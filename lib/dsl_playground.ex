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

    quote do: unquote(Macro.escape(result))
  end

  defmacro second_dsl(expr) do
    # expr =>
    # [do: {:__block__, [line: 13],
    #   [{:hoge, [line: 15], [1]},
    #    {:moge, [line: 16], [[do: {:fuga, [line: 17], [2]}]]}]}]

    {:__block__, _, val} = Keyword.get(expr, :do)
    # val =>
    # [{:hoge, [line: 15], [1]},
    #  {:moge, [line: 16], [[do: {:fuga, [line: 17], [2]}]]}]


    quote do: %{hoge: 1, moge: %{fuga: 2}}
  end

  def build_map(ast) do
    # [{:hoge, [line: 15], [1]},
    #  {:moge, [line: 16], [[do: {:fuga, [line: 17], [2]}]]}]
    %{hoge: 1, moge: %{fuga: 2}}
  end
end
