# =============================================================================
# GUION DE CLASE — Semana 5 · Sesión 2: group_by() y Aplicaciones
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Nombre: [TU NOMBRE]      Fecha: [FECHA]
#
# CÓMO USAR: corre cada línea con Cmd/Ctrl+Enter.
#   🔵 CORRE Y OBSERVA · ✏️ COMPLETA (____) · 🔮 PREDICE · 🟢 TU TURNO · ✅ Deberías ver
# =============================================================================

library(dplyr)

# Retomamos donde quedamos, ya con la experiencia de Mincer (Sesión 1)
casen <- read.csv("data/raw/casen_reducido.csv") |>
  mutate(experiencia = pmax(edad - educ - 6, 0))


# -----------------------------------------------------------------------------
# BLOQUE A — group_by(): el cambio de significado
# -----------------------------------------------------------------------------
# 👀 SOLO MIRA — así quedamos en la Sesión 1: un solo número para todo
casen |> summarise(ing = mean(ingreso, na.rm = TRUE))

# 🔵 CORRE Y OBSERVA — el MISMO summarise, pero un número POR REGIÓN
casen |>
  group_by(region) |>
  summarise(n = n(), ing = mean(ingreso, na.rm = TRUE))

# ✅ Deberías ver: 5 filas (una por región). Ñuble la más alta, con 696692.3

# 💡 LA GRAN IDEA: group_by() no cambia los datos. Cambia el SIGNIFICADO de lo
#    que viene después. Es "partir la tabla en pedazos y resumir cada pedazo".
#    Patrón: split (partir) - apply (aplicar) - combine (juntar).

# ✏️ COMPLETA: ahora el mismo resumen, pero agrupando por género.
casen |>
  group_by(genero) |>
  summarise(n = n(), ing = mean(ingreso, na.rm = TRUE))

# ✅ Deberías ver: F 29 636296.3  |  M 31 673607.1

# 🔮 PREDICE: ¿de cuánto es la brecha en pesos? ¿Se puede concluir de aquí que
#    en Chile los hombres ganan más? Anota tu respuesta: La brecha es de $37.311, 
#    puede concluírse que en esta muestra, los hombres ganan más, en promedio, 
#    que las mujeres.


# -----------------------------------------------------------------------------
# BLOQUE B — group_by() + mutate(): cuando NO quieres colapsar
# -----------------------------------------------------------------------------
# summarise() borra a las personas: agrupando por sector quedan 6 filas, una por
# sector. Pero a veces la cifra del grupo se necesita AL LADO de cada persona,
# no en vez de ella.

# 🔮 PREDICE: si cambio summarise() por mutate(), ¿cuántas filas salen?
#    ¿6 (una por sector) o 60 (todas las personas)? Anota: 60

casen |>
  group_by(sector) |>
  mutate(ing_sector = mean(ingreso, na.rm = TRUE)) |>
  ungroup() |>
  nrow()

casen |>
  group_by(sector) |>
  summarise(ing_sector = mean(ingreso, na.rm = TRUE)) |>
  nrow()

# ✅ Deberías ver: 60 con mutate() y 6 con summarise().

# 💡 LA REGLA: mismo group_by(), dos destinos distintos.
#      summarise() -> COLAPSA: una tabla de GRUPOS (para comparar sectores)
#      mutate()    -> CONSERVA: una tabla de PERSONAS con la cifra de su grupo

# 🔵 CORRE Y OBSERVA — para qué sirve: la brecha de cada persona con su sector
casen |>
  group_by(sector) |>
  mutate(ing_sector = mean(ingreso, na.rm = TRUE),
         brecha     = ingreso - ing_sector) |>
  ungroup() |>
  select(sector, ingreso, ing_sector, brecha) |>
  head(4)

# ✅ Deberías ver, en las dos primeras filas de Agricultura (media 447846.2):
#    +72153.85 y +19153.85. La tercera fila (Industria) tiene ingreso NA,
#    así que su brecha también es NA: correcto, no se inventa.

# ⚠️ GOTCHA: después de group_by() la tabla queda AGRUPADA y los verbos
#    siguientes siguen operando por grupo. ungroup() la cierra.
#    (En summarise() el equivalente es .groups = "drop".)

# 🟢 TU TURNO: ¿cuántas personas ganan MÁS que el promedio de SU REGIÓN?
#    Pista: crea la indicadora con mutate() agrupado y súmala.
casen |>
  group_by(region) |>
  mutate(sobre_media = ingreso > mean(ingreso, na.rm = TRUE)) |>
  ungroup() |>
  summarise(cuantos = sum(sobre_media, na.rm = TRUE))

# ✅ Deberías ver: 28  (de las 55 personas con ingreso conocido)
#
# 🔮 PREDICE: ¿por qué NO son 30, la mitad exacta de 60? Porque la media no es la mediana.


# -----------------------------------------------------------------------------
# BLOQUE C — Varios estadísticos a la vez
# -----------------------------------------------------------------------------
# ✏️ COMPLETA: agrega la mediana y la desviación estándar.
casen |>
  group_by(sector) |>
  summarise(n    = n(),
            prom = mean(ingreso, na.rm = TRUE),
            med  = median(ingreso, na.rm = TRUE),
            desv = sd(ingreso, na.rm = TRUE))

# ✅ Deberías ver: 6 sectores. Agricultura la más baja (447846),
#    Educación la más alta (908857): el doble.

# 🔮 PREDICE: mira la columna n. ¿De qué sector NO te fiarías del promedio?
#    ¿Por qué? Del sector construcción, comercio y educación en ese orden, puesto que el n es muy pequeño.


# -----------------------------------------------------------------------------
# BLOQUE D — arrange(): ordenar
# -----------------------------------------------------------------------------
# 🔵 CORRE Y OBSERVA — los 3 ingresos más altos
casen |> arrange(desc(ingreso)) |> select(region, educ, ingreso) |> head(3)

# ✅ Deberías ver: 1093000, 987000, 975000 (los dos primeros de Ñuble)

# ⚠️ GOTCHA: arrange() ordena de MENOR A MAYOR por defecto.
#    Para mayor a menor hay que envolver en desc().

# 🟢 TU TURNO: el uso más potente de arrange() es ordenar el RESULTADO de un
#    summarise, para convertir una tabla en un ranking. Complétalo:
casen |>
  group_by(region) |>
  summarise(ing = mean(ingreso, na.rm = TRUE)) |>
  arrange(desc(ing))

# ✅ Deberías ver el ranking: Ñuble, Maule, Araucanía, Metropolitana, Biobío


# -----------------------------------------------------------------------------
# BLOQUE E — Agrupar por DOS variables
# -----------------------------------------------------------------------------
# 🔵 CORRE Y OBSERVA — la brecha de género, ahora separando por educación
casen |>
  mutate(superior = educ >= 13) |>
  group_by(genero, superior) |>
  summarise(n = n(), ing = mean(ingreso, na.rm = TRUE), .groups = "drop")

# ✅ Deberías ver 4 filas (2 géneros x 2 niveles):
#    F FALSE 505929 | F TRUE 776692 | M FALSE 568143 | M TRUE 779071

# 🔮 PREDICE antes de interpretar: ¿qué le pasa a la brecha de género cuando
#    la persona tiene educación superior? Disminuye.

# 💡 EL HALLAZGO: con educación superior la brecha casi desaparece (~0,3 %);
#    sin ella es de ~62.000 pesos (~12 %). OJO con el lenguaje: la brecha
#    SE ASOCIA con el nivel educativo. NO demostramos que la educación la CAUSE
#    (para eso harían falta controles y otro diseño).

# ⚠️ GOTCHA: .groups = "drop" evita un mensaje de dplyr. Sin él, el resultado
#    queda todavía agrupado por genero y el siguiente verbo se comporta raro.


# -----------------------------------------------------------------------------
# BLOQUE F — Workflow completo: una pregunta, un pipe
# -----------------------------------------------------------------------------
# PREGUNTA: ¿en qué sector rinde más cada año de educación, considerando solo
#           sectores con al menos 8 casos?
# 🟢 TU TURNO: completa la cadena.
casen |>
  filter(!is.na(ingreso)) |>                    # 1. fuera los sin dato
  mutate(ing_por_educ = ingreso / educ) |>      # 2. ingreso por año de educación
  group_by(sector) |>                             # 3. partir por sector
  summarise(n = n(), ipe = mean(ing_por_educ)) |>   # 4. resumir
  filter(n >= 8) |>                             # 5. fuera los grupos chicos
  arrange(desc(ipe))                            # 6. ranking

# ✅ Deberías ver 3 filas: Servicios (63787.64), Industria (52665.85),
#    Agricultura (36176.47)

# 🔮 PREDICE: ¿por qué desapareció Educación, que en el Bloque B tenía el
#    ingreso promedio más alto? Porque tiene menos de 8 casos.
#
# 💡 Respuesta: solo tiene 7 casos con ingreso válido, así que el filter(n >= 8)
#    lo descarta. Sin ese filtro aparecería 2º — pero con n = 7 el promedio no
#    es confiable. Descartarlo es correcto, y hay que DECIRLO al reportar.

# 💡 Nota fina: filter() aparece dos veces con sentidos distintos. Antes de
#    agrupar filtra PERSONAS; después de summarise filtra GRUPOS.


# -----------------------------------------------------------------------------
# CIERRE — group_by (partir) · summarise (colapsar) · mutate (conservar) ·
#          arrange (ordenar). Patrón split - apply - combine.
# Esta semana cierra con la T2 (calificada, 13 %): tu propia pregunta,
#   respondida con estos verbos.
# Puente Semana 6: los datos reales vienen sucios y con forma incómoda ->
#   pivotear, faltantes y outliers.
# =============================================================================
