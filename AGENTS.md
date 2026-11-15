# Exercism (Elixir track)

## Añadir un nuevo ejercicio

1. Descargar el ejercicio:

   ```sh
   exercism download --exercise=<slug> --track=elixir
   ```

   El CLI ya está configurado con `workspace: /home/toyos/Projects/Elixir/exercism`, así
   que se descarga directamente en `/home/toyos/Projects/Elixir/exercism/elixir/<slug>`
   — no hace falta mover nada.

   **Cada ejercicio descargado debe quedar preparado con Credo y Dialyzer en ese
   momento**. Completar los pasos 3 y 4, incluido `mix deps.get`, antes de dar por
   terminada la incorporación del ejercicio. No aplazar su instalación al chequeo final.

2. Añadirlo al workspace de VS Code:

   Editar `exercism.code-workspace` y agregar una entrada en `folders` (orden alfabético):

   ```json
   { "path": "<slug>" }
   ```

3. Añadir Dialyzer (para practicar `@spec`):

   En `deps()` del `mix.exs` del ejercicio:

   ```elixir
   {:dialyxir, "~> 1.4", only: [:dev], runtime: false}
   ```

   Y en `project()`, apuntar la PLT a una ruta compartida fuera del proyecto (evita
   reconstruir el análisis de Erlang/Elixir en cada ejercicio). Hay que fijar tanto
   `plt_core_path` como `plt_local_path` — la PLT combinada grande (la lenta de construir)
   usa `plt_local_path`, que por defecto cae en `_build/` del proyecto si no se indica:

   ```elixir
   dialyzer: [
     plt_core_path: Path.expand("~/.cache/dialyxir_plts"),
     plt_local_path: Path.expand("~/.cache/dialyxir_plts")
   ]
   ```

   Luego `mix deps.get`.

4. Añadir Credo (linter de estilo y buenas prácticas):

   En `deps()` del `mix.exs` del ejercicio:

   ```elixir
   {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
   ```

   Luego `mix deps.get` y `mix credo` para revisar. Si avisa de `@moduledoc` faltante,
   añadir uno breve (en inglés) al módulo.

5. Quitar los `@tag :pending` de los tests, para que `mix test` ejecute todos los tests
   sin necesidad de `--include pending`. Borrar las líneas completas, incluidas las
   comentadas (`# @tag :pending`):

   ```sh
   sed -i -E '/^\s*(#\s*)?@tag :pending\s*$/d' <slug>/test/*_test.exs
   ```

## Chequeo final

Cuando el usuario pida el "chequeo final" (o equivalente) de un ejercicio, consiste en:

Si Credo o Dialyzer faltan en un ejercicio existente, configurarlos como se indica
arriba y ejecutar `mix deps.get` antes de continuar.

1. Comprobar que todas las funciones públicas (y, si tiene sentido, las privadas) tienen `@spec` — añadir los que falten, antes de ejecutar los tests.
2. `mix test --include pending` — deben pasar todos los tests.
3. `mix format --check-formatted` — si falla, ejecutar `mix format`.
4. `mix credo` — intentar arreglar los avisos que salgan.
5. `mix dialyzer` — intentar arreglar los avisos que salgan.

## Preferencias de estilo del usuario

El usuario prefiere código Elixir legible, explícito y con una complejidad
algorítmica razonada. Aplicar estas preferencias al implementar o refactorizar.
Favorecer refactors pequeños y justificados que conserven el comportamiento.
Estas preferencias no autorizan a completar partes del ejercicio que el usuario
todavía quiere resolver por su cuenta.

### Funciones y nombres

- Usar funciones pequeñas con una responsabilidad clara y nombres en inglés que
  expresen su propósito. Preferir `parse_board` a nombres que describan toda la
  representación interna, y `count_adjacent_flowers` para una función que cuenta.
- Separar pasos conceptuales: generar candidatos, comprobar cuáles cumplen una
  condición, contar y dar formato al resultado. Por ejemplo, generar coordenadas
  vecinas y después contar con `Enum.count/2` las que contienen una flor.
- Extraer helpers cuando aclaren una responsabilidad. Fusionar funciones que solo
  añadan un nivel de indirección sin aportar significado; evitar abstracciones
  innecesarias y no perseguir la máxima concisión.
- Dar a las variables nombres de dominio (`rows`, `copy_counts`, `first_roll`), no
  el del tipo que contienen (`str_list`). Se aceptan los nombres cortos
  idiomáticos: `n`, `c` para un carácter en parsers, `acc`, `rest`.
- Definir las guardas con `defguardp is_*` (`is_full`, `is_letter`): en Elixir el
  prefijo `is_` se reserva para lo que puede usarse en guardas. Las funciones
  booleanas normales terminan en `?` (`win?`, `flower_at?`). No mezclar las dos
  convenciones (`positive?` como guarda, `is_valid?` como función).
- Los helpers recursivos con acumulador usan el mismo nombre con otra aridad
  (`numeral/1` → `numeral/2`) o un nombre que describa el paso (`score_frames`).
  Evitar el prefijo `do_`.
- Ignorar valores con nombre (`_first_roll`, `_rest`) cuando aporte significado.

### Pattern matching y control de flujo

- Preferir pattern matching y cláusulas de función para casos simples; evitar
  anidamiento excesivo de `if` o `case`.
- Para nombrar un argumento que además se desestructura, usar siempre
  `name = pattern` (`state = %{size: 0}`, `word = [vowel | _]`), nunca
  `pattern = name`. Credo avisa si se mezclan los dos órdenes en un proyecto.
- En la cabecera, extraer solo los campos que usa la cláusula.
- Elegir la estructura de control según el caso:
  - cláusulas de función: casos según la forma o el valor de la entrada;
  - `with`: cadena de pasos que pueden fallar con `{:ok, _}` / `{:error, _}`,
    sin `else` si el error se propaga tal cual;
  - `case`: ramificar sobre el resultado de una expresión;
  - `cond`: condiciones booleanas ordenadas que no caben en una guarda;
  - `if` en línea (`if condition, do: a, else: b`): solo para elecciones simples
    entre dos opciones.

### Pipelines y forma de las funciones

- Usar pipelines para expresar transformaciones sucesivas de forma fácil de leer:
  - preferir empezar con el dato (`board |> ...`) en lugar de con una llamada
    (`parse_board(input) |> ...`), sin forzarlo cuando obligue a crear una
    variable temporal que no aporta nada;
  - poner paréntesis en cada paso (`|> rows()`, no `|> rows`);
  - no usar pipes de un solo paso: `String.replace(str, " ", "")`, no
    `str |> String.replace(" ", "")`;
  - usar `then/1` solo para un último ajuste corto; si la función anónima crece,
    extraer un helper con nombre.
- Si una función (o una cláusula) tiene una sola expresión, usar la forma corta
  `do:` en lugar de `do ... end`, p. ej.
  `defp position({row, col}), do: %{row: row + 1, column: col + 1}`. Vale
  aunque `mix format` deje la cabecera en una línea y `do: <expresión>` en la
  siguiente, siempre que la expresión quepa en una sola línea. Si `mix format`
  tuviera que partir la propia expresión en varias líneas (pipelines largos,
  comprensiones `for`, structs que no caben), mantener `do ... end`. Los
  pipelines con más de dos `|>` también mantienen `do ... end`, con un paso por
  línea, aunque quepan en una sola.

### Datos y complejidad

- Elegir las estructuras de datos según las operaciones: listas para recorridos
  secuenciales, tuplas para acceso frecuente por índice, mapas para consultas por
  clave y `MapSet` para pertenencia o visitados. Evitar recorridos repetidos y
  conversiones innecesarias; considerar su coste asintótico.
- Mantener los datos originales como fuente de consulta y construir el resultado
  mediante transformaciones, por ejemplo con comprensiones que conserven las filas.
- Acumular con `[x | acc]` y `Enum.reverse/1` al final; no usar `acc ++ [x]`
  dentro de un bucle (es O(n²)).
- Preferir `Enum` y comprensiones (`for` con `into:` o `reduce:`) para recorrer
  colecciones, también con corte temprano (`Enum.find_value/2`,
  `Enum.reduce_while/3`). Usar recursión con cláusulas cuando cada paso consuma un
  número variable de elementos o haya una máquina de estados (los frames de
  bowling consumen una o dos tiradas; un parser consume prefijos de distinta
  longitud).
- Guardar constantes y tablas en atributos de módulo, calculadas en compilación si
  se derivan de otras (`@scores` construido con un `for`,
  `@payment_cards Map.keys(@penalties)`). Usar una tupla si se accede por índice
  (`@cost_per_group`).

### Módulos y procesos

- Mantener pública solo la API necesaria. Los helpers internos deben ser privados;
  comprobar su comportamiento mediante la API pública en lugar de exponerlos solo
  para escribir tests.
- Extraer un concepto a su propio módulo (anidado o en el mismo archivo), con
  `defstruct`, `@type t` y sus funciones, solo cuando tenga varias operaciones
  propias y extraerlo simplifique el módulo principal (`Tournament.Results`,
  `GameOfLife.Matrix`, `BitMasks`). Un struct que solo guarda el estado interno
  puede quedarse en el módulo principal, como en `CircularBuffer`. No crear
  módulos que solo reenvían llamadas; si hace falta reenviar, usar `defdelegate`.
- Procesos (`Agent`, `GenServer`):
  - la lógica va en funciones puras sobre el estado (como `push/2` o
    `drop_oldest/1` en `CircularBuffer`), privadas o en un módulo aparte; la capa
    del proceso solo las llama;
  - usar `start_link`, no `start`;
  - si el proceso no existe, dejar que falle, salvo que el ejercicio pida un error
    concreto;
  - `Agent` si solo hay estado y operaciones sobre él; `GenServer` si hacen falta
    `handle_info`, timeouts u otros callbacks.
- Parsers: funciones recursivas sobre el binario que casan prefijos
  (`" plus " <> rest`, `<<c, rest::binary>> when c in ?0..?9`) y devuelven
  `{:ok, value, rest} | {:error, reason}`, encadenadas con `with`. Un tipo
  paramétrico (`@type parsed(value) :: {:ok, value, String.t()} | error()`) evita
  repetir esa forma en los specs.

### Tipos y specs

- Añadir `@spec` a las funciones y usar tipos de dominio como `coord()` o `board()`
  cuando reduzcan repetición y aclaren la intención. Los tipos deben reflejar los
  valores reales, incluidas coordenadas negativas al generar vecinos.
- Notación: tipos predefinidos sin paréntesis, como en los stubs de Exercism
  (`integer`, `boolean`, `String.t()`); tipos propios con paréntesis (`coord()`,
  `t()`); listas como `[coord()]`, no `list(coord())`.
- `@type t` para los structs, `@typep` para los tipos internos (estado, caché) y
  `@opaque` para handles que no se deben inspeccionar desde fuera.
- Precisar los valores: errores concretos (`{:error, :full}`, no
  `{:error, atom}`), rangos cuando acotan (`0..10`, `1..4`) y nombres dentro de
  las tuplas si aclaran (`{row :: integer, col :: integer}`).

### Orden, documentación y comentarios

- Orden en el módulo: `@moduledoc`, `defstruct`, tipos y atributos antes del primer
  `@doc` (un `@doc` encima de `defstruct` se asigna a `__struct__/0`). Un solo
  `@doc` y un solo `@spec` antes de la primera cláusula de cada función.
- Mantener nombres y documentación del código en inglés. `@moduledoc` breve; en las
  funciones puras, ejemplos `iex>` que funcionen como doctests.
- Añadir comentarios para explicar decisiones o restricciones poco evidentes, sin
  narrar operaciones obvias. El comentario de una función va encima de su `@spec`,
  no entre el `@spec` y el `def`; el de una cláusula concreta, justo encima de esa
  cláusula.

### Tests

- Los módulos auxiliares públicos (como `BitMasks`) tienen sus tests en
  `test/<modulo>_test.exs`, con un `describe` por función y `doctest Modulo`.
  Cuando exista una fórmula conocida, añadir casos generales con bucles
  (`for n <- 0..8`) que comparen el resultado con ella.

## Cómo ayudar a resolver un ejercicio

El usuario quiere ir descubriendo la solución paso a paso, no que se resuelva el ejercicio completo de una vez.

- Si pregunta algo general tipo "¿cómo se soluciona esto?", "¿cómo lo hago?", "¿por dónde empiezo?" sobre un ejercicio o una parte de él: explica el enfoque, los conceptos o pistas necesarias, pero **no escribas la implementación completa**. Deja que sea el usuario quien escriba el código, o como mucho da un fragmento pequeño/parcial si hace falta para desbloquear.
- Si pregunta algo puntual y acotado (un error concreto, "por qué falla este test", "cómo hago X función específica"), respóndelo directamente como siempre — esta regla no aplica a dudas puntuales, solo a peticiones generales de "resuélveme esto".
- Si el usuario quiere que resuelvas el ejercicio (o una tarea/task_id) completo de una vez, tiene que decirlo explícitamente (p. ej. "resuélvelo entero", "impleméntalo completo", "hazlo todo"). Sin esa indicación explícita, asume que quiere ir paso a paso.
