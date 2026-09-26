import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import streamlit as st

st.set_page_config(page_title="Tablero de cartera", page_icon="📈", layout="wide")
BANDAS_EDAD = [17, 30, 35, 45, 50, 55, 60, 95]

st.title("Tablero de cartera - auto")
st.write("Autor: Eric Daniel Hernandez Jardon")
st.write("Fecha: 2024-06-18")

def ruta_datos():
    """Devuelve la primera ruta que exista. Evita el clásico FileNotFoundError."""
    for r in ["../../datos/datos.parquet",
              "../datos/datos.parquet",
              "../../Modulo_4/m4t2_sesion1/datos/datos.parquet",
              "../../../Modulo_4/m4t2_sesion1/datos/datos.parquet"
              "C:/Users/gusta/OneDrive/Documentos/Diplomado/github/diplomado-ml-gustavo-rodriguez-ayala/m5t1_sesion1/datos/datos.parquet"]:
        if os.path.exists(r):
            return r
    raise FileNotFoundError("No encuentro datos.parquet. Ponlo en una carpeta 'datos/'.")

@st.cache_data
def cargar_datos():
    print("Cargando datos...")
    df = pd.read_parquet(ruta_datos())
    df["edad_cat"] = pd.cut(df["edad_conductor"], bins=BANDAS_EDAD)
    return df

def kpi_frecuencia(df):
    """Σ siniestros / Σ exposición (ponderada por exposición)."""
    return df['num_siniestros'].sum() / df['exposicion'].sum()

def kpi_severidad_media(df):
    """Ponderada por nº de siniestros, solo sobre pólizas con N>0."""
    con = df[df['num_siniestros'] > 0]
    return np.average(con['severidad'], weights=con['num_siniestros']) if len(con) else np.nan

def kpi_prima_pura(df):
    """Σ monto / Σ exposición (= frecuencia * severidad)."""
    return df['monto_total'].sum() / df['exposicion'].sum()

def kpis_por(df, var):
    """Devuelve un DataFrame con los KPIs por cada categoría de la variable `var`."""
    filas = []
    for niv, g in df.groupby(var, observed=True):
        filas.append({
            var: str(niv),
            'exposicion': g['exposicion'].sum(),
            'frecuencia': kpi_frecuencia(g),
            'severidad': kpi_severidad_media(g),
            'prima_pura': kpi_prima_pura(g)
        })
    return pd.DataFrame(filas).sort_values('exposicion', ascending=False).reset_index(drop=True)

datos = cargar_datos()

st.write(f"Cartera cargada: **{len(datos):,}** pólizas - **{datos.shape[1]}** columnas")

st.dataframe(datos.head(10))

freq = kpi_frecuencia(datos)
st.metric("Frecuencia de la cartera", f"{freq:.4f}")

sev = kpi_severidad_media(datos)
st.metric("Severidad media", f"${sev:,.0f}")

prima_pura = kpi_prima_pura(datos)
st.metric("Prima pura", f"${prima_pura:,.0f}")

REF_M4 = 0.1392
ok = abs(freq - REF_M4) < 0.05
st.caption(f"Validación vs. M4: referencia ≈ {REF_M4} · calculado = {freq:.4f} ->"
           + ("✅ coincide" if ok else "⚠️ NO coincide, revisa la fórmula"))

cobertura = st.selectbox("Selecciona una cobertura para ver su frecuencia",
                         options=sorted(datos["cobertura"].unique()))

df = datos[datos["cobertura"] == cobertura]
st.metric(f"Frecuencia de la cobertura {cobertura}", f"{kpi_frecuencia(df):.4f}")
st.caption(f"{len(df):,} pólizas con cobertura {cobertura}")

st.info("Edita este archivo, guarda, y el navegador te ofrecerá **Rerun**.")