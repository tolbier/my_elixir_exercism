# Reescribir ListOps con foldl y foldr

Puedes reescribir `count`, `reverse`, `map` y `filter`, eliminando sus auxiliares privados:

```elixir
def count(l), do: foldl(l, 0, fn _, acc -> acc + 1 end)

def reverse(l), do: foldl(l, [], fn x, acc -> [x | acc] end)

def map(l, f) do
  l
  |> foldl([], fn x, acc -> [f.(x) | acc] end)
  |> reverse()
end

def filter(l, f) do
  l
  |> foldl([], fn x, acc ->
    if f.(x), do: [x | acc], else: acc
  end)
  |> reverse()
end
```

Así mantienes la recursión de cola y ejecutas `f` de izquierda a derecha, igual que ahora.

## Alternativa con foldr

```elixir
def map(l, f), do: foldr(l, [], fn x, acc -> [f.(x) | acc] end)

def filter(l, f) do
  foldr(l, [], fn x, acc ->
    if f.(x), do: [x | acc], else: acc
  end)
end
```

Ambas versiones conservan el orden de los resultados, pero con `foldr` **`f` se ejecuta de derecha a izquierda**.

Mantendría tu implementación actual de `foldr`:

```elixir
def foldr(l, acc, f), do: foldl(reverse(l), acc, f)
```

Como usa `reverse`, es importante que `reverse` dependa de `foldl`; si lo implementaras mediante `foldr`, crearías un ciclo infinito.

Ya usas `foldr` adecuadamente en `append/2` y `concat/1`.
