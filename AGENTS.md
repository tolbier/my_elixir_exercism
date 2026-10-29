# Exercism (Elixir track)

## Añadir un nuevo ejercicio

1. Descargar el ejercicio:

   ```
   exercism download --exercise=<slug> --track=elixir
   ```

   El CLI ya está configurado con `workspace: /home/toyos/exercism`, así que se descarga
   directamente en `/home/toyos/exercism/elixir/<slug>` — no hace falta mover nada.

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

## Chequeo final

Cuando el usuario pida el "chequeo final" (o equivalente) de un ejercicio, consiste en:

Si Credo o Dialyzer faltan en un ejercicio existente, configurarlos como se indica
arriba y ejecutar `mix deps.get` antes de continuar.

1. Comprobar que todas las funciones públicas (y, si tiene sentido, las privadas) tienen `@spec` — añadir los que falten, antes de ejecutar los tests.
2. `mix test --include pending` — deben pasar todos los tests.
3. `mix credo` — intentar arreglar los avisos que salgan.
4. `mix dialyzer` — intentar arreglar los avisos que salgan.

## Cómo ayudar a resolver un ejercicio

El usuario quiere ir descubriendo la solución paso a paso, no que se resuelva el ejercicio completo de una vez.

- Si pregunta algo general tipo "¿cómo se soluciona esto?", "¿cómo lo hago?", "¿por dónde empiezo?" sobre un ejercicio o una parte de él: explica el enfoque, los conceptos o pistas necesarias, pero **no escribas la implementación completa**. Deja que sea el usuario quien escriba el código, o como mucho da un fragmento pequeño/parcial si hace falta para desbloquear.
- Si pregunta algo puntual y acotado (un error concreto, "por qué falla este test", "cómo hago X función específica"), respóndelo directamente como siempre — esta regla no aplica a dudas puntuales, solo a peticiones generales de "resuélveme esto".
- Si el usuario quiere que resuelvas el ejercicio (o una tarea/task_id) completo de una vez, tiene que decirlo explícitamente (p. ej. "resuélvelo entero", "impleméntalo completo", "hazlo todo"). Sin esa indicación explícita, asume que quiere ir paso a paso.
