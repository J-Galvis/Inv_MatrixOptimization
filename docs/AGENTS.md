# AGENTS.md

## Comandos de compilación y ejecución

### Compilación con Make
```bash
make              # Compila todas las variantes
make clean        # Limpia los binarios en output/
```

### Compilación manual
- **Secuencial:** `gcc src/SecuentialMatrixSolver.c -o output/secuential -Wall -O2`
- **Memoria optimizada:** `gcc src/MemoryMatrixSolver.c -o output/memory -Wall -O2 -pthread`
- **Hilos:** `gcc src/ThreadsMatrixSolver.c -o output/threads -Wall -O2 -pthread`
- **Multiprocesamiento:** `gcc src/MultiprocessingMatrixSolver.c -o output/multiprocessing -Wall -O2`

### Ejecución de variantes
```bash
./output/<variante> <filas> [<num_hilos | num_procesos>]
```

Ejemplos:
```bash
./output/secuential 4
./output/threads 4 2
./output/memory 4
./output/multiprocessing 4 2
```

---

## Ejecución de pruebas

### Prueba unitaria básica (2x2)
Ejecutar con tamaño de matriz pequeño:
```bash
./output/secuential 2
./output/threads 2 2
./output/multiprocessing 2 2
./output/memory 2
```

### Prueba unitaria 3x3
Para verificar corrección de multiplicación:
1. Descomentar `test_3x3();` en el `main` del archivo fuente correspondiente
2. Compilar y ejecutar
3. Comentar nuevamente antes de committing

```bash
# En src/SecuentialMatrixSolver.c línea 103:
test_3x3(); //descomentar para probar

gcc src/SecuentialMatrixSolver.c -o output/secuential -Wall -O2
./output/secuential 3
```

### Scripts automáticos
- **RunAll.sh:** Ejecuta todas las variantes para múltiples tamaños
  ```bash
  chmod +x scripts/RunAll.sh
  ./scripts/RunAll.sh
  ```
  Resultados en `stats/<hostname>/`

- **testing.sh:** Ejecuta pruebas secuenciales múltiples
  ```bash
  chmod +x scripts/testing.sh
  ./scripts/testing.sh
  ```

---

## Guía de estilo y convenciones

### Importaciones
- Todos los `#include` al inicio del archivo, uno por línea
- Sin líneas vacías entre includes
- Usar solo las cabeceras estándar requeridas
- Orden: stdio.h, stdlib.h, luego otros

### Formato y sangría
- **Sangría:** 4 espacios por nivel (NUNCO usar tabuladores)
- **Llaves:** Apertura al final de la línea de declaración
- **Funciones:** Separar siempre con una línea en blanco
- **Líneas:** Máximo 100-120 caracteres por línea

### Nomenclatura
- **Funciones y variables:** `snake_case` (e.g., `create_matrix`, `user_time`)
- **Structs:** `PascalCase` (e.g., `struct MatrixInfo`)
- **Constantes:** `MAYUSCULAS_CON_BAJOS` (e.g., `MAX_SIZE`)
- **Variables cortas válidas:** `rows`, `cols`, `matrix`, `A`, `B`, `C`, `i`, `j`, `k`
- **Idioma:** NO usar español en nombres de variables o funciones

### Tipos y declaraciones
- Usar tipos explícitos: `int`, `double`, `int**`, etc.
- Punteros con espacio: `int** matrix` (no `int**matrix`)
- Casts explícitos en malloc: `(int**)malloc(...)`
- Prefijos de punteros cuando sea útil: `pMatrix`, `pRow`

### Manejo de errores
- **Memoria:** Siempre liberar memoria asignada dinámicamente (`free_matrix()`, `munmap()`)
- **Códigos de retorno:** Funciones retornar `1` para éxito, `0` para error
- **Errores:** Imprimir mensajes a stderr/consola con información relevante
- **Recursos:** Verificar liberación en todos los paths de ejecución (incluyendo errores)

### Comentarios
- **Español:** Comentarios en español (excepto tecnicismos de C)
- **Bloques:** Documentar funciones, decisiones de concurrencia, manejo de recursos
- **Estilo:** `//` para comentarios de línea, `/* */` para bloques
- **Inline:** Evitar comentarios excesivos en líneas individuales

### Salida de resultados (CRÍTICO)
- **Tiempos:** Siempre 6 decimales: `printf("%.6f,", tiempo_usuario);`
- **Formato:** NO modificar el formato de salida existente
- **Inmutabilidad:** Scripts automáticos dependen del formato exacto

---

## Instrucciones para agentes

### Antes de modificar código
1. Probar con matrices 2x2 y 3x3 (usando `test_3x3()` si es necesario)
2. Verificar que la multiplicación es correcta
3. Confirmar liberación de memoria sin fugas

### Después de modificar código
1. Ejecutar pruebas con tamaños pequeños (2, 3, 4)
2. Verificar que los tiempos de ejecución son razonables
3. Comprobar que no hay fugas de memoria

### Restricciones
- NO eliminar ni sobrescribir funciones `test_3x3()`
- NO realizar refactors profundos que sacrifiquen claridad
- NO modificar formato de salida sin aprobación
- NO agregar dependencias externas sin consenso

### Documentación
- Nueva convención, macro o script → registrar en este archivo
- Idioma base: español (documentación, comentarios, scripts)
- Excepciones: tecnicismos de C y nombres de funciones estándar

---

## Estructura del proyecto

```
/home/daniel/HPC/
├── src/
│   ├── SecuentialMatrixSolver.c     # Implementación secuencial básica
│   ├── MemoryMatrixSolver.c         # Optimización de memoria
│   ├── ThreadsMatrixSolver.c        # Paralelismo con hilos
│   └── MultiprocessingMatrixSolver.c # Paralelismo con procesos
├── output/                          # Binarios compilados
├── scripts/
│   ├── RunAll.sh                    # Ejecuta todas las variantes
│   └── testing.sh                   # Pruebas secuenciales múltiples
├── stats/                           # Resultados de ejecuciones
├── Makefile                         # Build system
├── README.md                        # Documentación principal
└── docs/AGENTS.md                   # Este archivo
```

---

## Notas adicionales

- Proyecto escrito en C con enfoque en HPC (High Performance Computing)
- Cada variante implementa multiplicación de matrices con diferentes técnicas de optimización
- Los tiempos se miden con `getrusage()` para precisión de CPU user time
- El formato CSV de salida permite procesamiento automático de estadísticas
