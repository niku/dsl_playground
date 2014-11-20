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

  defmacro third_dsl(expr) do
    quote do: unquote(Macro.escape(new_build_map(expr)))
  end

  def build_map(ast) do
    # ast =>
    # [{:hoge, [line: 15], [1]},
    #  {:moge, [line: 16], [[do: {:fuga, [line: 17], [2]}]]}]

    reduce_ast(Map.new, ast)
  end

  def new_build_map(ast) do
    # ast =>
    # [do: {:__block__, [line: 23],
    #   [{:hoge, [line: 25], [1]},
    #    {:moge, [line: 26],
    #     [[do: {:__block__, [line: 23],
    #        [{:fuga, [line: 27], [2]},
    #         {:foo, [line: 28],
    #          [[do: {:bar, [line: 29], [[do: {:baz, [line: 30], [3]}]]}]]}]}]]}]}]
    new_reduce_ast(Map.new, ast)
  end

  defp new_reduce_ast(map, [do: {:__block__, _, v}]) do
    new_reduce_ast(map, v)
  end

  defp new_reduce_ast(map, [do: {k, _, [v]}]) do
    value = new_reduce_ast(Map.new, v)
    new_reduce_ast(Dict.put(map, k, value), [])
  end

  defp new_reduce_ast(map, {k, _, [v]}) do
    new_reduce_ast(Dict.put(map, k, v), [])
  end

  defp new_reduce_ast(map, [{k, _, [v]}|tail]) when is_list(v) do
    value = new_reduce_ast(Map.new, v)
    new_reduce_ast(Dict.put(map, k, value), tail)
  end

  defp new_reduce_ast(map, [{k, _, [v]}|tail]) do
    new_reduce_ast(Dict.put(map, k, v), tail)
  end

  defp new_reduce_ast(map, []), do: map
  defp new_reduce_ast(_map, v), do: v

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
