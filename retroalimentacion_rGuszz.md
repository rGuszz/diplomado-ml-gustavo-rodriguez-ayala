# Retroalimentación — Gustavo Rodríguez Ayala
**Repo:** https://github.com/rGuszz/diplomado-ml-gustavo-rodriguez-ayala
**Fecha de evaluación:** 2026-05-12
**Calificación final:** 9.88 / 10

## Resumen general
Excelente entrega.

## Desglose por sesión

### Sesión 1 — Instalación y configuración de Python — 1/1 pt
Archivo: `diplomado-ml-gustavo-rodriguez-ayala\Modulo_1\sesion_1\sesion1_M1_notebook.ipynb`. 32 de 32 celdas de código con contenido ejecutable.

### Sesión 2 — Tipos de datos básicos — 1/1 pt
Archivo: `diplomado-ml-gustavo-rodriguez-ayala\Modulo_1\sesion_2\sesion2_M1_notebook.ipynb`. 24 de 24 celdas de código con contenido ejecutable.

### Sesión 3 — Estructuras de datos + control de flujo — 1/1 pt
Archivo: `diplomado-ml-gustavo-rodriguez-ayala\Modulo_1\sesion_3\sesion3_M1_notebook.ipynb`. 29 de 29 celdas de código con contenido ejecutable.

### Sesión 4 — Funciones — 1/1 pt
Archivo: `diplomado-ml-gustavo-rodriguez-ayala\Modulo_1\sesion_4\sesion4_M1_notebook.ipynb`. 22 de 22 celdas de código con contenido ejecutable.

### Sesión 5 — Módulos / funciones avanzadas — 2.00/2 pts
Archivo: `diplomado-ml-gustavo-rodriguez-ayala\Modulo_1\sesion_5\sesion5_M1_notebook.ipynb`.
- Notebook ejecutable: **0.5/0.5**
- Ejercicios completos: **0.5/0.5**
- Resultados correctos: **1.0/1.0**
- Las 3 tareas integradoras tienen código.
- Notebook ejecuta end-to-end sin errores.

### Sesión 6 — Módulos propios + inicio de Pandas — 2.0/2 pts
Archivo: `diplomado-ml-gustavo-rodriguez-ayala\Modulo_1\sesion_6\sesion6_M1_notebook.ipynb`.
- Notebook ejecutable: **0.5/0.5**
- Ejercicios completos: **0.5/0.5**
- Resultados correctos: **1.0/1.0**  _(re-evaluado con comparación numérica estricta contra canónico)_
  - Tarea 1: ✓ correcta (18/20 números coinciden)
  - Tarea 2: ✓ correcta (20/25 números coinciden)
  - Tarea 3: ✓ correcta (12/14 números coinciden)

### Sesión 7 — Pandas avanzado — 1.88/2 pts
Archivo: `diplomado-ml-gustavo-rodriguez-ayala\Modulo_1\sesion_7\sesion7_M1_notebook.ipynb`.
- Notebook ejecutable: **0.5/0.5**
- Ejercicios completos: **0.5/0.5**
- Resultados correctos: **0.88/1.0**  _(re-evaluado con comparación numérica estricta contra canónico)_
  - Tarea 1: ✓ correcta (15/15 números coinciden)
  - Tarea 2: ✓ correcta (18/18 números coinciden)
  - Tarea 3: ✓ correcta (30/30 números coinciden)
  - Tarea 4: ◐ parcial (11/15 números coinciden con el canónico)


## Parte 2 — Sesiones 8 y 11

### Sesión 8 — Pipeline Completo — 1.73/2 pts
*(solo se evaluó el Ejercicio Integrador Final)*
- Corre hasta el Integrador: 0.50/0.5
- Integrador Final, 5 fases: 1.23/1.5
  - FASE 1: 0.80*0.3 = 0.24 (coinciden algunos numeros clave (20%))
  - FASE 2: 0.90*0.3 = 0.27 (mayoria de numeros coinciden (40%))
  - FASE 3: 1.00*0.3 = 0.30 (numeros coinciden (50% de canon cubierto))
  - FASE 4: 0.70*0.3 = 0.21 (codigo extenso (45 lineas) ejecuta; printeos no coinciden con canonico)
  - FASE 5: 0.70*0.3 = 0.21 (codigo extenso (34 lineas) ejecuta; printeos no coinciden con canonico)

### Sesión 11 — Práctica Final — 1.00/8 pts
*(solo se evaluó el Ejercicio Integrador Final "Mini Pricing Actuarial")*
- Corre hasta el Integrador: 1.00/1.0
  - FASE 1: 0.00*1.75 = 0.00 (celda vacia o solo placeholder)
  - FASE 2: 0.00*1.75 = 0.00 (celda vacia o solo placeholder)
  - FASE 3: 0.00*1.75 = 0.00 (celda vacia o solo placeholder)
  - FASE 4: 0.00*1.75 = 0.00 (celda vacia o solo placeholder)
- _Nota:_ Usado outputs guardados del alumno (la re-ejecucion tuvo demasiados errores).

## Bonus — Sesiones 9 y 10
- S9 entregada correctamente: **Sí** (integrador correcto (100% de numeros coinciden))
- S10 entregada correctamente: **Sí** (mpl_ok=True sb_ok=True)
- Bonus aplicado: **+0.5**

## Calificación final
- Parte 1: 9.88 / 10
- Parte 2: 2.73 / 10
- Promedio: 6.305 / 10
- Bonus: +0.5
- **Final: 6.81 / 10**

---

# Retroalimentación — Módulo 4 · Tema 2 (GLM con Python)

**Alumno:** Rodríguez Ayala, Gustavo
**Variable asignada:** `cobertura`

## Desglose por pregunta

| Pregunta | Pts | Comentario |
|---|---|---|
| P1 | 6/10 | Citas correctamente φ=1.1664 y el resultado de Cameron-Trivedi, y reconoces la sobredispersión leve. Sin embargo, la conclusión queda ambigua: dices que "lo ideal es usar QuasiPoisson... o bien pasar a una Binomial Negativa", sin decidir. Con φ<1.5 el punto es que QuasiPoisson **basta** y Binomial Negativa no es necesaria (se reserva para φ>2) — tu respuesta no llega a esa conclusión clara. |
| P2 | 9/10 | RC (+7.9%) y Limitada (−5.55%) bien identificados frente a Amplia, revisión correcta de IC/p-values, decisión de mantener los 3 niveles. |
| P3 | 8/10 | Explicación correcta de las ecuaciones de estimación y del aporte del GLM (modelos multivariados, validación estadística), aunque más breve que en otras preguntas. |
| P4 | 9/10 | CV constante, Lognormal fuera de la familia exponencial natural, y necesidad de corrección de sesgo al volver de log(Y) a Y — completa y correcta. |
| P5 | 9/10 | Elección correcta de Binomial Negativa con AIC/BIC citados, buena explicación del pseudo R² bajo como algo normal en seguros. |
| P6 | 6/10 | Dices que frecuencia y severidad "van en direcciones opuestas", pero tus propios números matizan eso: Limitada es el nivel más bajo tanto en frecuencia (0.9445) como en severidad (0.6681) — es decir, coincide en ambas. Solo RC realmente invierte dirección (sube en frecuencia, baja en severidad). La conclusión final (modelar por separado) es correcta, pero la lectura de "opuesto" está sobresimplificada respecto a lo que muestra la tabla. |
| P7 | 9/10 | Buena distinción entre calibración (ratio 1.0249, "solo sobreestima 2.49%") y discriminación (Gini 0.2315, moderada). |
| P8 | 9/10 | RC más alto (+5.18%) y Limitada más bajo (−10.39%) bien identificados y traducidos correctamente. |
| P9 | 7/10 | Buena síntesis de frecuencia (RC) y severidad (Amplia con mayor costo medio), y de la tarifa resultante. Sin embargo falta incluir el intervalo de confianza de algún rating factor, como pide la consigna para un estilo defendible ante CNSF. |

## Redacción: 7/10

## Nota final: 79/100 (calificación: 7.9/10)

## Comentarios generales
Buen manejo general de los conceptos: identificas correctamente los rating factors de tu variable, las métricas de validación y la tarifa resultante en casi todas las preguntas. Los dos puntos a reforzar son: (1) en P1, decide con claridad entre QuasiPoisson y Binomial Negativa en función de la magnitud de φ, en vez de dejar ambas opciones abiertas; (2) en P6, revisa tu propia tabla con más cuidado antes de calificar la relación como "opuesta" — Limitada muestra la misma dirección (baja) en ambas métricas, y solo RC es realmente el caso que ilustra la divergencia entre frecuencia y severidad.
