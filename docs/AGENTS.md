# AGENTS.md

## Comandos para compilación y ejecución

- Para compilar cada variante:
  - **Secuencial:**
    `gcc src/SecuentialMatrixSolver.c -o output/secuential`
  - **Memoria optimizada:**
    `gcc src/MemoryMatrixSolver.c -O3 -o output/memory`
  - **Hilos:**
    `gcc src/ThreadsMatrixSolver.c -o output/threads -lpthread`
  - **Multiprocesamiento:**
    `gcc src/MultiprocessingMatrixSolver.c -o output/multiprocessing`

- Para ejecutar una variante manualmente:
  ```bash
  ./output/<variante> <filas> [<num_hilos | num_procesos>]
  ```
  Ejemplo:
  ```bash
  ./output/secuential 4
  ./output/threads 4 2
  ./output/multiprocessing 4 2
  ```

---

## Ejecución de pruebas unitarias

- Para ejecutar una prueba pequeña, descomenta la llamada a `test_3x3()` en el `main` de la variante que deseas probar.
- Compila y ejecuta el binario resultante.
- La salida será la matriz resultado de la multiplicación conocida.
- Comenta nuevamente la línea antes de dejar el código.

---

## Uso de scripts automáticos

- `scripts/RunAll.sh` ejecuta todas las variantes para diferentes tamaños de matriz y guarda los resultados en `stats/<hostname>/`.
  - Ejecutar con:
    ```bash
    chmod +x scripts/RunAll.sh # (solo una vez)
    ./scripts/RunAll.sh
    ```
    Los archivos generados tendrán información separada para cada método y tamaño.

- `scripts/testing.sh` ejecuta pruebas secuenciales múltiples y archiva los resultados de salidas en archivos incrementales.
  - Ejecutar con:
    ```bash
    chmod +x scripts/testing.sh # (solo una vez)
    ./scripts/testing.sh
    ```

---

## Guía de estilo y convenciones

**Importaciones**
- Todos los `#include` deben ir al inicio, uno por línea, ninguna línea vacía entre ellos.
- Usa solo las cabeceras estándar requeridas para la variante.

**Formato y sangría**
- Sangría de 4 espacios por nivel (no usar tabuladores).
- Llaves de apertura al final de la línea de declaración de función, ciclo o bloque.
- Separar funciones siempre con una línea en blanco.

**Nomenclatura**
- Nombres de funciones y variables en snake_case.
- Nombres de structs en PascalCase.
- Nombres de variables cortos pero descriptivos (`rows`, `cols`, `matrix`, `A`, `B`, `C`).
- No usar español en nombres internos de variables o funciones.

**Manejo de errores y memoria**
- Siempre liberar la memoria asignada dinámicamente al final (`free_matrix()`, `munmap()`).
- Usar y retornar códigos de estado en funciones (`1` éxito, `0` error) si es necesario.
- Imprimir errores relevantes a consola cuando se manejen.
- En cambios, evitar fugas de memoria por asignación dinámica mal liberada.

**Comentarios**
- Anteponer comentarios explicativos a funciones y bloques relevantes, en español.
- Usar `//` para comentarios en línea, y documentar cualquier decisión de concurrencia, manejo de recursos o particularidad de C.

**Salida de resultados**
- Tiempos de CPU siempre con 6 decimales: `printf("%.6f,", tiempo_usuario);`
- No modificar el formato de salida, vital para estadísticas y scripts automáticos.

---

## Instrucciones generales para agentes automatizados

- Realizar pruebas con matrices 2x2 y 3x3 (habilitando `test_3x3()` si es necesario) antes de dar por finalizada cualquier modificación.
- Mantener funcionalidad de los bloques de pruebas unitarias, nunca eliminar ni sobrescribir `test_3x3`.
- Verificar la correcta liberación de memoria y recursos tras la realización de pruebas.
- No realizar refactors profundos ni modularizaciones innecesarias si se sacrifica claridad o compatibilidad.
- Toda nueva convención, script, macro o ajuste debe ser registrado en este mismo archivo para consulta futura.
- El idioma base para documentación, comentarios y scripts es el español, excepto tecnicismos imprescindibles propios del lenguaje C.

---

_Si se agregan reglas de formateo, linting o automatización (como archivos para copilot, cursor, etc.), deben ser descritos en una sección propia dentro de este archivo._