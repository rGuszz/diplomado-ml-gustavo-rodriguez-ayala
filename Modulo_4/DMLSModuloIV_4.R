# ==============================================================================
# OHLSSON - PRIMA PURA DE RIESGO
# MODELO MULTIPLICATIVO (FRECUENCIA POISSON × SEVERIDAD LOGNORMAL)
# ==============================================================================


# ==============================================================================
# 1. LIBRERÍAS
# ==============================================================================

library(dplyr)
library(ggplot2)
library(tweedie)
library(statmod)
library(insurancerating)
library(DHARMa)


# ==============================================================================
# 2. CARGA DE DATOS
# ==============================================================================

ruta <- "C:/Users/gusta/OneDrive/Documentos/Diplomado/github/diplomado-ml-gustavo-rodriguez-ayala/Modulo_4/Ohlsson.csv"
Ohlsson <- read.csv(ruta)

cat("\n============================================\n")
cat("INFORMACIÓN DE LA BASE\n")
cat("============================================\n")
cat("Observaciones originales:", nrow(Ohlsson), "\n")
cat("Variables:", ncol(Ohlsson), "\n")


# ==============================================================================
# 3. LIMPIEZA Y PREPROCESAMIENTO
# ==============================================================================

ohlsson_clean <- subset(
  Ohlsson,
  duration > 0 &
    antskad >= 0 &
    skadkost >= 0
)

# Conversión de variables categóricas a factores
ohlsson_clean$kon     <- as.factor(ohlsson_clean$kon)
ohlsson_clean$zon     <- as.factor(ohlsson_clean$zon)
ohlsson_clean$mcklass <- as.factor(ohlsson_clean$mcklass)
ohlsson_clean$bonuskl <- as.factor(ohlsson_clean$bonuskl)

# Prima pura observada por unidad de exposición
ohlsson_clean$pure_premium_obs <- ohlsson_clean$skadkost / ohlsson_clean$duration

cat("\n============================================\n")
cat("LIMPIEZA\n")
cat("============================================\n")
cat("Observaciones eliminadas:", nrow(Ohlsson) - nrow(ohlsson_clean), "\n")
cat("Observaciones finales:", nrow(ohlsson_clean), "\n")
cat("Valores NA:", sum(is.na(ohlsson_clean)), "\n")


# ==============================================================================
# 4. MÉTRICAS BASE DEL PORTAFOLIO
# ==============================================================================

exposicion_total       <- sum(ohlsson_clean$duration)
siniestros_totales     <- sum(ohlsson_clean$antskad)
costo_total_observado  <- sum(ohlsson_clean$skadkost)
frecuencia_observada   <- siniestros_totales / exposicion_total
severidad_observada    <- costo_total_observado / siniestros_totales
prima_pura_observada   <- costo_total_observado / exposicion_total

cat("\n============================================\n")
cat("PORTAFOLIO\n")
cat("============================================\n")
cat("Exposición total:", round(exposicion_total, 2), "\n")
cat("Siniestros totales:", siniestros_totales, "\n")
cat("Costo total observado:", round(costo_total_observado, 2), "\n")
cat("Frecuencia observada:", round(frecuencia_observada, 6), "\n")
cat("Severidad observada:", round(severidad_observada, 2), "\n")
cat("Prima pura observada:", round(prima_pura_observada, 2), "\n")


# ==============================================================================
# 5. ANÁLISIS DEL RIESGO POR EDAD CON GAM
# ==============================================================================

age_freq <- risk_factor_gam(
  data = ohlsson_clean,
  risk_factor = "agarald",
  claim_count = "antskad",
  exposure = "duration"
)

autoplot(age_freq, show_observations = TRUE)

age_segments <- derive_tariff_segments(age_freq)
autoplot(age_segments)

ohlsson_clean <- ohlsson_clean |>
  add_tariff_segments(age_segments, name = "age_freq") |>
  mutate(across(where(is.character), as.factor))


# ==============================================================================
# 6. MODELO DE FRECUENCIA - POISSON GLM
# ==============================================================================

glm_freq <- glm(
  antskad ~
    age_freq +
    zon +
    fordald,
  family = poisson(link = "log"),
  offset = log(duration),
  data = ohlsson_clean,
  control = glm.control(maxit = 100)
)

cat("\n============================================\n")
cat("MODELO DE FRECUENCIA - POISSON\n")
cat("============================================\n")
print(summary(glm_freq))
cat("\nAIC Poisson:", round(AIC(glm_freq), 2), "\n")


# ==============================================================================
# 7. DIAGNÓSTICO Y VALIDACIÓN DE FRECUENCIA
# ==============================================================================

set.seed(123)
res_freq <- check_residuals(glm_freq, n_simulations = 250)
autoplot(res_freq)

# Dispersión de Pearson
dispersion <- sum(residuals(glm_freq, type = "pearson")^2) / glm_freq$df.residual
cat("Dispersión de Pearson:", round(dispersion, 4), "\n")

if (dispersion > 1.5) {
  cat("Existe evidencia de SOBREDISPERSIÓN.\n")
} else {
  cat("La dispersión es compatible con Poisson.\n")
}

# Residuos DHARMa
simulation_res <- simulateResiduals(fittedModel = glm_freq, plot = FALSE)
par(mar = c(4, 4, 2, 1))
plot(simulation_res)


# ==============================================================================
# 8. PREDICCIÓN DE FRECUENCIA
# ==============================================================================

ohlsson_clean$pred_freq <- predict(
  glm_freq,
  newdata = ohlsson_clean,
  type = "response"
)

cat("\nSiniestros observados:", sum(ohlsson_clean$antskad), "\n")
cat("Siniestros predichos:", round(sum(ohlsson_clean$pred_freq), 2), "\n")

bootstrap_performance(glm_freq, ohlsson_clean, n_resamples = 100, show_progress = FALSE) |>
  autoplot()


# ==============================================================================
# 9. PREPARACIÓN DE DATOS PARA SEVERIDAD
# ==============================================================================

# Filtrar únicamente pólizas con siniestros y costos positivos
claims_data <- subset(
  ohlsson_clean,
  antskad > 0 &
    skadkost > 0
)

# Severidad promedio por siniestro y su transformación logarítmica
claims_data$avg_claim <- claims_data$skadkost / claims_data$antskad
claims_data$log_severity <- log(claims_data$avg_claim)

cat("\n============================================\n")
cat("ESTADÍSTICAS DE SEVERIDAD\n")
cat("============================================\n")
cat("Pólizas con siniestros:", nrow(claims_data), "\n")
cat("Severidad promedio:", round(mean(claims_data$avg_claim), 2), "\n")
cat("Severidad mediana:", round(median(claims_data$avg_claim), 2), "\n")
cat("Severidad máxima:", round(max(claims_data$avg_claim), 2), "\n")

# Histograma y curva normal teórica
hist(
  claims_data$avg_claim,
  breaks = 50,
  main = "Distribución de la severidad promedio",
  xlab = "Severidad promedio por siniestro",
  ylab = "Frecuencia",
  col = "lightblue",
  border = "white"
)

mu <- mean(claims_data$log_severity)
sigma <- sd(claims_data$log_severity)

curve(
  dnorm(x, mean = mu, sd = sigma),
  add = TRUE,
  lwd = 2
)


# ==============================================================================
# 10. MODELO DE SEVERIDAD - LOGNORMAL (GLM GAUSSIANO)
# ==============================================================================

glm_sev <- glm(
  log_severity ~
    age_freq +
    zon +
    fordald,
  family = gaussian(link = "identity"),
  data = claims_data
)

cat("\n============================================\n")
cat("RESULTADOS MODELO LOGNORMAL\n")
cat("============================================\n")
print(summary(glm_sev))
cat("\nAIC Lognormal:", round(AIC(glm_sev), 2), "\n")

# R² basado en devianza
r2_logsev <- 1 - (glm_sev$deviance / glm_sev$null.deviance)
cat("\nR² (Deviance Explained):", round(r2_logsev, 4), "\n")

# R² ajustado
n <- length(residuals(glm_sev))
p <- length(coef(glm_sev)) - 1
r2_adj <- 1 - ((glm_sev$deviance / (n - p - 1)) / (glm_sev$null.deviance / (n - 1)))
cat("R² ajustado:", round(r2_adj, 4), "\n")


# ------------------------------------------------------------------------------
# 10.1 Diagnóstico y validación de residuos (Severidad)
# ------------------------------------------------------------------------------

set.seed(123)
res_sev <- check_residuals(glm_sev, n_simulations = 250)
autoplot(res_sev)

# Validación DHARMa
set.seed(123)
sim_res_sev <- simulateResiduals(fittedModel = glm_sev, plot = FALSE)
par(mar = c(4, 4, 2, 1))
plot(sim_res_sev)


# ------------------------------------------------------------------------------
# 10.2 Desempeño por Bootstrapping (RMSE simulado)
# ------------------------------------------------------------------------------

set.seed(123)
n_sim <- 250
rmse_simulado <- numeric(n_sim)

for (i in 1:n_sim) {
  idx <- sample(nrow(claims_data), replace = TRUE)
  data_boot <- claims_data[idx, ]
  
  modelo_boot <- glm(
    log_severity ~ age_freq + zon + fordald,
    family = gaussian(link = "identity"),
    data = data_boot
  )
  
  preds <- predict(modelo_boot, newdata = data_boot)
  rmse_simulado[i] <- sqrt(mean((data_boot$log_severity - preds)^2))
}

df_perf <- data.frame(RMSE = rmse_simulado)
preds_original <- predict(glm_sev, newdata = claims_data)
rmse_original <- sqrt(mean((claims_data$log_severity - preds_original)^2))

ggplot(df_perf, aes(x = RMSE)) +
  geom_histogram(aes(y = after_stat(density)), bins = 20, fill = "gray80", alpha = 0.6, color = "white") +
  geom_density(color = "#1f78b4", linewidth = 1) +
  geom_vline(xintercept = rmse_original, color = "#ff7f00", linetype = "dashed", linewidth = 1) +
  labs(
    title = "Bootstrapped model performance",
    subtitle = "Simulated RMSE distribution for Severity Model",
    x = "(Simulated) RMSE",
    y = "Density"
  ) +
  theme_minimal()


# ==============================================================================
# 11. PREDICCIÓN DE SEVERIDAD EN TODO EL PORTAFOLIO
# ==============================================================================

sigma2 <- summary(glm_sev)$dispersion

# 1. Copia de seguridad y tratamiento de colas en edades sin siniestros observados
datos_prediccion <- ohlsson_clean
levels(datos_prediccion$age_freq)[levels(datos_prediccion$age_freq) %in% c("(70,77]", "(77,92]")] <- "(63,70]"

# 2. Predicción en escala link asegurando vector plano con unname()
pred_log_severity_all <- predict(
  glm_sev, 
  newdata = datos_prediccion,
  type = "link"
)

# 3. Retransformación a escala original aplicando la corrección de varianza (sigma^2 / 2)
ohlsson_clean$pred_sev <- exp(unname(pred_log_severity_all) + sigma2 / 2)


# ==============================================================================
# 12. CÁLCULO DE PRIMA PURA (FRECUENCIA × SEVERIDAD)
# ==============================================================================

ohlsson_clean$pred_claim_fs <- ohlsson_clean$pred_freq * ohlsson_clean$pred_sev

fs_total        <- sum(ohlsson_clean$pred_claim_fs, na.rm = TRUE)
fs_pure_premium <- fs_total / exposicion_total


# ==============================================================================
# 13. EVALUACIÓN DE DESEMPEÑO Y MÉTRICAS FINALES
# ==============================================================================

mae_fs  <- mean(abs(ohlsson_clean$skadkost - ohlsson_clean$pred_claim_fs))
rmse_fs <- sqrt(mean((ohlsson_clean$skadkost - ohlsson_clean$pred_claim_fs)^2))

r2_fs <- 1 - sum((ohlsson_clean$skadkost - ohlsson_clean$pred_claim_fs)^2) /
  sum((ohlsson_clean$skadkost - mean(ohlsson_clean$skadkost))^2)

cat("\n============================================\n")
cat("MÉTRICAS FINALES - FRECUENCIA × SEVERIDAD\n")
cat("============================================\n")
cat("Costo total observado:", round(costo_total_observado, 2), "\n")
cat("Costo total predicho:", round(fs_total, 2), "\n")
cat("Prima pura observada:", round(prima_pura_observada, 2), "\n")
cat("Prima pura predicha:", round(fs_pure_premium, 2), "\n")
cat("Diferencia porcentual:", round((fs_total / costo_total_observado - 1) * 100, 2), "%\n")
cat("MAE:", round(mae_fs, 2), "\n")
cat("RMSE:", round(rmse_fs, 2), "\n")
cat("R²:", round(r2_fs, 4), "\n")


# ============================================================
# 14. MODELO TWEEDIE
# ============================================================

glm_tweedie <- glm(
  pure_premium_obs ~
    kon +
    zon +
    mcklass +
    bonuskl +
    agarald +
    fordald,
  family = statmod::tweedie(
    var.power = 1.5,
    link.power = 0
  ),
  weights = duration,
  data = ohlsson_clean,
  control = glm.control(maxit = 100)
)

cat("\n============================================\n")
cat("MODELO TWEEDIE\n")
cat("============================================\n")

print(summary(glm_tweedie))

cat(
  "\nAIC Tweedie:",
  round(
    AIC(glm_tweedie),
    2
  ),
  "\n"
)


# ============================================================
# 15. PREDICCIÓN TWEEDIE
# ============================================================

ohlsson_clean$pred_pure_tweedie <-
  predict(
    glm_tweedie,
    newdata = ohlsson_clean,
    type = "response"
  )


# Costo esperado por póliza
ohlsson_clean$pred_claim_tw <-
  ohlsson_clean$pred_pure_tweedie *
  ohlsson_clean$duration


# Costo total predicho
tw_total <-
  sum(
    ohlsson_clean$pred_claim_tw
  )


# Prima pura predicha
tw_pure_premium <-
  tw_total /
  exposicion_total


# ============================================================
# 16. MÉTRICAS TWEEDIE
# ============================================================

mae_tw <-
  mean(
    abs(
      ohlsson_clean$skadkost -
        ohlsson_clean$pred_claim_tw
    )
  )

rmse_tw <-
  sqrt(
    mean(
      (
        ohlsson_clean$skadkost -
          ohlsson_clean$pred_claim_tw
      )^2
    )
  )

r2_tw <-
  1 -
  sum(
    (
      ohlsson_clean$skadkost -
        ohlsson_clean$pred_claim_tw
    )^2
  ) /
  sum(
    (
      ohlsson_clean$skadkost -
        mean(ohlsson_clean$skadkost)
    )^2
  )


cat("\n============================================\n")
cat("RESULTADOS TWEEDIE\n")
cat("============================================\n")

cat(
  "Costo total observado:",
  round(
    costo_total_observado,
    2
  ),
  "\n"
)

cat(
  "Costo total predicho:",
  round(
    tw_total,
    2
  ),
  "\n"
)

cat(
  "Prima pura observada:",
  round(
    prima_pura_observada,
    2
  ),
  "\n"
)

cat(
  "Prima pura predicha:",
  round(
    tw_pure_premium,
    2
  ),
  "\n"
)

cat(
  "Diferencia porcentual:",
  round(
    (
      tw_total /
        costo_total_observado -
        1
    ) * 100,
    2
  ),
  "%\n"
)

cat(
  "MAE:",
  round(
    mae_tw,
    2
  ),
  "\n"
)

cat(
  "RMSE:",
  round(
    rmse_tw,
    2
  ),
  "\n"
)

cat(
  "R²:",
  round(
    r2_tw,
    4
  ),
  "\n"
)


# ============================================================
# 17. COMPARACIÓN FINAL
# ============================================================

comparacion <- data.frame(
  
  Modelo = c(
    "Frecuencia x Severidad",
    "Tweedie"
  ),
  
  Costo_Observado = c(
    costo_total_observado,
    costo_total_observado
  ),
  
  Costo_Predicho = c(
    fs_total,
    tw_total
  ),
  
  Prima_Pura_Observada = c(
    prima_pura_observada,
    prima_pura_observada
  ),
  
  Prima_Pura_Predicha = c(
    fs_pure_premium,
    tw_pure_premium
  ),
  
  Diferencia_Porcentual = c(
    (
      fs_total /
        costo_total_observado -
        1
    ) * 100,
    
    (
      tw_total /
        costo_total_observado -
        1
    ) * 100
  ),
  
  MAE = c(
    mae_fs,
    mae_tw
  ),
  
  RMSE = c(
    rmse_fs,
    rmse_tw
  ),
  
  R2 = c(
    r2_fs,
    r2_tw
  )
)


# Redondear resultados

comparacion$Costo_Observado <-
  round(
    comparacion$Costo_Observado,
    2
  )

comparacion$Costo_Predicho <-
  round(
    comparacion$Costo_Predicho,
    2
  )

comparacion$Prima_Pura_Observada <-
  round(
    comparacion$Prima_Pura_Observada,
    2
  )

comparacion$Prima_Pura_Predicha <-
  round(
    comparacion$Prima_Pura_Predicha,
    2
  )

comparacion$Diferencia_Porcentual <-
  round(
    comparacion$Diferencia_Porcentual,
    2
  )

comparacion$MAE <-
  round(
    comparacion$MAE,
    2
  )

comparacion$RMSE <-
  round(
    comparacion$RMSE,
    2
  )

comparacion$R2 <-
  round(
    comparacion$R2,
    4
  )


cat("\n\n============================================\n")
cat("             COMPARACIÓN FINAL\n")
cat("============================================\n")

print(comparacion)


# ============================================================
# 18. CONCLUSIÓN
# ============================================================

cat("\n============================================\n")
cat("                 CONCLUSIÓN\n")
cat("============================================\n")


if (mae_fs < mae_tw) {
  
  cat(
    "Menor MAE: Frecuencia × Severidad\n"
  )
  
} else {
  
  cat(
    "Menor MAE: Tweedie\n"
  )
}


if (rmse_fs < rmse_tw) {
  
  cat(
    "Menor RMSE: Frecuencia × Severidad\n"
  )
  
} else {
  
  cat(
    "Menor RMSE: Tweedie\n"
  )
}


cat(
  "\nPrima pura observada:",
  round(
    prima_pura_observada,
    2
  ),
  "\n"
)

cat(
  "Prima pura Frecuencia × Severidad:",
  round(
    fs_pure_premium,
    2
  ),
  "\n"
)

cat(
  "Prima pura Tweedie:",
  round(
    tw_pure_premium,
    2
  ),
  "\n"
)

cat("Prima pura Tweedie:", round(tw_pure_premium, 2), "\n")