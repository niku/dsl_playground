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

    quote do: unquote(Macro.escape(build_map(val)))
  end

  def build_map(ast) do
    # ast =>
    # [{:hoge, [line: 15], [1]},
    #  {:moge, [line: 16], [[do: {:fuga, [line: 17], [2]}]]}]

    reduce_ast(Map.new, ast)
  end

  defp reduce_ast(map, [head|tail]) when is_tuple(head) do
    # map =>
    # %{}
    # head =>
    # {:hoge, [line: 15], [1]}
    # tail =>
    # [{:moge, [line: 16], [[do: {:fuga, [line: 17], [2]}]]}]

    {k, _, v} = head
    # k =>
    # :hoge
    # v =>
    # [1]

    new_map = Dict.put(map, k, reduce_ast(Map.new, v))
    # new_map =>
    # %{hoge: 1}

    if tail === [] do
      new_map
    else
      reduce_ast(new_map, tail)
    end
  end

  defp reduce_ast(map, [head|tail]) when is_list(head) do
    # map =>
    # %{}
    # head =>
    # [do: {:fuga, [line: 17], [2]}]
    # tail =>
    # []

    block_stripped = Keyword.get(head, :do)
    # block_stripped =>
    # {:fuga, [line: 17], [2]}

    reduce_ast(map, [block_stripped|tail])
  end

  defp reduce_ast(_map, [head|_tail]) do
    # _map =>
    # %{}
    # head =>
    # 1
    # _tail =>
    # []

    head
  end
end
