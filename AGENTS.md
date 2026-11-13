# Exercism (Elixir track)

## Añadir un nuevo ejercicio

1. Descargar el ejercicio:

   ```
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

   ```
   sed -i -E '/^\s*(#\s*)?@tag :pending\s*$/d' <slug>/test/*_test.exs
   ```

## Chequeo final

Cuando el usuario pida el "chequeo final" (o equivalente) de un ejercicio, consiste en:

Si Credo o Dialyzer faltan en un ejercicio existente, configurarlos como se indica
arriba y ejecutar `mix deps.get` antes de continuar.

1. Comprobar que todas las funciones públicas (y, si tiene sentido, las privadas) tienen `@spec` — añadir los que falten, antes de ejecutar los tests.
2. `mix test --include pending` — deben pasar todos los tests.
3. `mix credo` — intentar arreglar los avisos que salgan.
4. `mix dialyzer` — intentar arreglar los avisos que salgan.

## Preferencias de estilo del usuario

El usuario prefiere código Elixir legible, explícito y con una complejidad
algorítmica razonada. Aplicar estas preferencias al implementar o refactorizar:

- Usar funciones pequeñas con una responsabilidad clara y nombres en inglés que
  expresen su propósito. Preferir `parse_board` a nombres que describan toda la
  representación interna, y `count_adjacent_flowers` para una función que cuenta.
- Separar pasos conceptuales: generar candidatos, comprobar cuáles cumplen una
  condición, contar y dar formato al resultado. Por ejemplo, generar coordenadas
  vecinas y después contar con `Enum.count/2` las que contienen una flor.
- Usar pipelines para expresar transformaciones sucesivas de forma fácil de leer.
  Preferir pattern matching y cláusulas de función para casos simples; evitar
  anidamiento excesivo de `if` o `case`.
- Si una función (o una cláusula) tiene una sola expresión, usar la forma corta
  `do:` en lugar de `do ... end`, p. ej.
  `defp position({row, col}), do: %{row: row + 1, column: col + 1}`. Vale
  aunque `mix format` deje la cabecera en una línea y `do: <expresión>` en la
  siguiente, siempre que la expresión quepa en una sola línea. Si `mix format`
  tuviera que partir la propia expresión en varias líneas (pipelines largos,
  comprensiones `for`, structs que no caben), mantener `do ... end`. Los
  pipelines con más de dos `|>` también mantienen `do ... end`, con un paso por
  línea, aunque quepan en una sola.
- Extraer helpers cuando aclaren una responsabilidad. Fusionar funciones que solo
  añadan un nivel de indirección sin aportar significado; evitar abstracciones
  innecesarias y no perseguir la máxima concisión.
- Elegir las estructuras de datos según las operaciones: listas para recorridos
  secuenciales, tuplas para acceso frecuente por índice, mapas para consultas por
  clave y `MapSet` para pertenencia o visitados. Evitar recorridos repetidos y
  conversiones innecesarias; considerar su coste asintótico.
- Mantener los datos originales como fuente de consulta y construir el resultado
  mediante transformaciones, por ejemplo con comprensiones que conserven las filas.
- Añadir `@spec` a las funciones y usar tipos de dominio como `coord()` o `board()`
  cuando reduzcan repetición y aclaren la intención. Los tipos deben reflejar los
  valores reales, incluidas coordenadas negativas al generar vecinos.
- Mantener pública solo la API necesaria. Los helpers internos deben ser privados;
  comprobar su comportamiento mediante la API pública en lugar de exponerlos solo
  para escribir tests.
- Mantener nombres y documentación del código en inglés. Añadir comentarios para
  explicar decisiones o restricciones poco evidentes, sin narrar operaciones obvias.
- Favorecer refactors pequeños y justificados que conserven el comportamiento.
  Estas preferencias no autorizan a completar partes del ejercicio que el usuario
  todavía quiere resolver por su cuenta.

## Cómo ayudar a resolver un ejercicio

El usuario quiere ir descubriendo la solución paso a paso, no que se resuelva el ejercicio completo de una vez.

- Si pregunta algo general tipo "¿cómo se soluciona esto?", "¿cómo lo hago?", "¿por dónde empiezo?" sobre un ejercicio o una parte de él: explica el enfoque, los conceptos o pistas necesarias, pero **no escribas la implementación completa**. Deja que sea el usuario quien escriba el código, o como mucho da un fragmento pequeño/parcial si hace falta para desbloquear.
- Si pregunta algo puntual y acotado (un error concreto, "por qué falla este test", "cómo hago X función específica"), respóndelo directamente como siempre — esta regla no aplica a dudas puntuales, solo a peticiones generales de "resuélveme esto".
- Si el usuario quiere que resuelvas el ejercicio (o una tarea/task_id) completo de una vez, tiene que decirlo explícitamente (p. ej. "resuélvelo entero", "impleméntalo completo", "hazlo todo"). Sin esa indicación explícita, asume que quiere ir paso a paso.
