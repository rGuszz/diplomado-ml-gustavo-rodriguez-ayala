# Evaluación — Módulo 4 · Tema 2: GLM con Python

**Alumno:** Gustavo
**Variable asignada:** `cobertura`  (cobertura)
**Fecha de entrega:** 13/09/2026

> **Instrucciones.** Este archivo evalúa las tres sesiones del tema. Las tablas ya vienen
> calculadas; tu trabajo es **responder las preguntas de interpretación** en el espacio
> "**Tu respuesta:**". Se evalúa la interpretación, no el código. Máx. 4–6 líneas por respuesta.
> Todas tus preguntas usan **tu variable asignada** (`cobertura`). Guarda y sube este archivo a tu repositorio.

---

## Parte 1 · Sesión 1 — Modelo de Frecuencia

**Diagnóstico del supuesto de Poisson (modelo completo):**

| métrica | valor |
| --- | --- |
| φ de Pearson | 1.1664 |
| Cameron-Trivedi α | 0.0744 |
| z | 15.80 |
| p-value | 3.7e-56 |

**Rating factors de frecuencia para `cobertura`** (base × RF reproduce la tasa empírica; diferencia máx = 2.4e-05):

| nivel | RF_frec | IC_inf | IC_sup | p | tasa_emp |
| --- | --- | --- | --- | --- | --- |
| Amplia (ref) | 1 | 1 | 1 | 0 | 0.1352 |
| Limitada | 0.9445 | 0.9017 | 0.9895 | 0.0161 | 0.1277 |
| RC | 1.079 | 1.0348 | 1.1251 | 0.0004 | 0.1459 |

**P1.** ¿Se cumple la equidispersión? Justifica con φ **y** con Cameron-Trivedi, y di qué familia usarías.
**Tu respuesta:** Definitivamente no se cumple la equidispersión. Al ver un phi de Pearson de 1.1664 sabemos que la varianza es mayor a la media, y la prueba de Cameron-Trivedi lo ratifica con un z muy alto (15.80) y p-value prácticamente en cero (3.7e-56). Como la sobredispersión que tenemos es moderada o leve (phi < 1.5), lo ideal es usar QuasiPoisson para corregir los errores estándar multiplicando por raíz de phi, o bien pasar a una Binomial Negativa para ajustar adecuadamente la variabilidad.

**P2.** Interpreta los rating factors de tu variable: nivel más alto y más bajo, traducidos a % de
recargo/descuento. ¿Algún IC cruza 1 o tiene p > 0.05? ¿Qué harías con ese nivel?
**Tu respuesta:** Tomando como base la cobertura Amplia (RF = 1), el riesgo de frecuencia más elevado está en RC con un RF de 1.0790, lo que significa un recargo del 7.9% en la frecuencia observada. Por otro lado, Limitada es el nivel más bajo con un RF de 0.9445, representando un descuento del 5.55% (1 - 0.9445). Ninguno de los intervalos de confianza abarca el 1 y todos los p-values están por debajo del 0.05, por lo que decido mantener los tres niveles sin agrupar ninguno.

**P3.** ¿Por qué el GLM one-way reproduce exactamente la tasa empírica, y qué aporta el GLM que una
tabla empírica no puede dar?
**Tu respuesta:** El GLM univariado coincide con la tasa empírica porque las ecuaciones de estimación con liga log y offset fuerzan a que los siniestros estimados igualen a los observados en cada categoría (exp(η) = Σn/Σe). La ventaja de usar el GLM sobre una simple tabla es que nos permite construir modelos multivariados para aislar el efecto real de cada variable controlando los demás factores, además de dar la validación estadística con p-values e intervalos de confianza.

---

## Parte 2 · Sesión 2 — Severidad y Selección de Modelos

**Comparación de modelos de frecuencia:**

| modelo | AIC | BIC | pseudoR2_McF |
| --- | --- | --- | --- |
| Poisson | 125,081.7 | 125,261.7 | 0.0198 |
| Binomial Negativa | 124,925.7 | 125,105.8 | 0.021 |

**Rating factors de severidad (Gamma) para `cobertura`:**

| nivel | RF_sev | severidad_emp |
| --- | --- | --- |
| Amplia (ref) | 1 | 1,589 |
| Limitada | 0.6681 | 1,061 |
| RC | 0.8533 | 1,356 |

**P4.** ¿Por qué se usa **Gamma** para severidad y no una regresión lineal sobre log(Y)? (menciona la
propiedad del CV y por qué Lognormal no es GLM).
**Tu respuesta:** La distribución Gamma se ajusta muy bien a la severidad porque asume un coeficiente de variación (CV) constante, lo cual refleja la heterocedasticidad típica del costo de los siniestros. La Lognormal no forma parte de la familia exponencial natural en la escala original de Y. Si usáramos MCO sobre log(Y) estaríamos modelando E[log Y] y necesitaríamos meter un factor de corrección exp(σ̂²/2) para regresar a E[Y], mientras que Gamma con liga log trabaja sobre E[Y] directamente y sin sesgar los resultados.

**P5.** Según la tabla de comparación, ¿qué modelo elegirías? Justifica con AIC/BIC. ¿Por qué el pseudo R²
es tan bajo y eso NO significa que el modelo sea malo?
**Tu respuesta:** Me quedo con la Binomial Negativa, ya que consigue valores menores tanto en AIC (124,925.7 vs 125,081.7) como en BIC (125,105.8 vs 125,261.7), acomodando mejor la sobredispersión del dataset. El pseudo R² ronda apenas el 0.02 porque la ocurrencia de un siniestro individual es un evento en gran medida aleatorio con muchísima variabilidad que ningún modelo puede explicar totalmente. En seguros esto es normal y no significa que el modelo falle; lo relevante es la significancia de los parámetros y la capacidad de ordenamiento.

**P6.** Compara tus rating factors de frecuencia (Parte 1) con los de severidad para `cobertura`. ¿Apuntan en
la misma dirección? ¿Qué implica eso para separar Frecuencia × Severidad?
**Tu respuesta:** Van en direcciones opuestas. En frecuencia el nivel con mayor riesgo es RC (RF = 1.0790) y el menor es Limitada (0.9445). En cambio, al revisar la severidad el costo promedio más alto se lo lleva Amplia ($1,589, base = 1.00), seguida de RC (0.8533) y Limitada (0.6681). Esto demuestra que lo que origina la frecuencia no influye de la misma forma en el costo del siniestro, respaldando la decisión de modelar Frecuencia y Severidad de forma separada para no distorsionar la prima pura.

---

## Parte 3 · Sesión 3 — Validación y Tarifa

**Validación out-of-sample del modelo de frecuencia:**

| metrica | valor | ideal |
| --- | --- | --- |
| Gini (test) | 0.2315 | > 0.30 aceptable |
| Ratio pred/obs (test) | 1.0249 | ≈ 1.00 |

**Prima pura por nivel de `cobertura`** (Frecuencia × Severidad, con su factor de tarifa):

| nivel | prima_pura_modelo | factor_tarifa |
| --- | --- | --- |
| Amplia (ref) | 182.29 | 0.9997 |
| Limitada | 163.39 | 0.8961 |
| RC | 191.77 | 1.0518 |

**P7.** Interpreta las métricas de validación: ¿el modelo está bien calibrado (ratio pred/obs)? ¿discrimina
bien el riesgo (Gini)? ¿Qué mide cada una?
**Tu respuesta:** El modelo muestra una calibración sólida en test, con un ratio pred/obs de 1.0249 que solo sobreestima un 2.49% el volumen global. Por su parte, el coeficiente Gini alcanza 0.2315, lo que señala una capacidad de discriminación moderada al quedar algo por debajo del 0.30 ideal. En resumen, el ratio pred/obs valida si le atinamos al monto total del portafolio, mientras que el Gini evalúa qué tan bien logramos ordenar los riesgos de menor a mayor.

**P8.** Lee la tabla de tarifa: ¿qué nivel de tu variable paga la prima pura más alta y cuál la más baja?
Traduce el factor de tarifa a un recargo/descuento sobre la prima promedio.
**Tu respuesta:** La prima pura más alta corresponde al nivel RC con $191.77 (factor de 1.0518), lo que implica aplicar un recargo del 5.18% sobre la prima promedio del portafolio. Por otro lado, la prima más baja es para Limitada con $163.39 (factor de 0.8961), representando un descuento del 10.39% (1 - 0.8961). La cobertura Amplia se queda en $182.29 con un factor de 0.9997, prácticamente pegada al promedio global.

**P9. (Conclusión de nota técnica).** En 3–4 líneas, redacta cómo `cobertura` afecta la tarifa, integrando
frecuencia, severidad y prima pura, en estilo defendible ante la CNSF.
**Tu respuesta:** La variable cobertura es un factor de riesgo técnicamente justificable para la segmentación de tarifa. La cobertura de Responsabilidad Civil (RC) destaca por su mayor frecuencia de siniestros (RF = 1.0790), mientras que la cobertura Amplia concentra el costo medio más elevado ($1,589). Al combinar ambos efectos en la prima pura técnica, se justifica ante la CNSF aplicar un recargo a la tarifa del +5.18% a RC y un descuento del -10.39% a Limitada con respecto al promedio del portafolio.

---
*Evaluación generada automáticamente · Diplomado ML en Seguros · FC UNAM · Módulo 4 · Tema 2*
