# =============================================================================
# GUION DE CLASE — Semana 5 · Sesión 1: Los 5 Verbos de dplyr
# Fundamentos de Programación para Análisis Económico · UdeC-EAN
#
# Nombre: Camila Bravo Figueroa      Fecha: 10/09/2026
#
# CÓMO USAR: corre cada línea con Cmd/Ctrl+Enter.
#   🔵 CORRE Y OBSERVA · ✏️ COMPLETA (____) · 🔮 PREDICE · 🟢 TU TURNO · ✅ Deberías ver
# =============================================================================

# 🔵 CORRE Y OBSERVA — cargar el paquete (instalar solo una vez, con install.packages)
library(dplyr)

# Este script se ejecuta desde la RAÍZ del proyecto (no desde guiones_clase/)
casen    <- read.csv("data/raw/casen_reducido.csv")
ingresos <- read.csv("data/raw/casen_ingresos.csv")   # las mismas 60 personas,
                                                      # con el ingreso desagregado
dim(casen)
names(casen)
sum(is.na(casen$ingreso))

# ✅ Deberías ver: 60 6 ... los 6 nombres ... y 5 valores faltantes en ingreso
# 💡 Esos 5 NA están puestos a propósito: los datos reales SIEMPRE tienen huecos.


# -----------------------------------------------------------------------------
# BLOQUE A — select(): elegir COLUMNAS
# -----------------------------------------------------------------------------
# 🔵 CORRE Y OBSERVA
select(casen, region, educ, ingreso)
head(select(casen, region, educ, ingreso), 3)

# ✅ Deberías ver: 60 filas, pero solo 3 columnas.

# Con el signo menos, se QUITA una columna
select(casen, -genero)

# ✏️ COMPLETA: quédate solo con edad e ingreso.
select(casen, edad, ingreso)

# 💡 select() nunca cambia el número de FILAS, solo de columnas.


# --- Elegir columnas por PATRÓN (cuando son muchas) --------------------------
# 🔵 CORRE Y OBSERVA — mira los nombres de la base desagregada
names(ingresos)

# ✅ Deberías ver 10 columnas, CUATRO de ellas empezando con "ing_".

# Escribirlas a mano es frágil: si mañana llega ing_arriendo, hay que acordarse.
# Mejor elegir por REGLA:
ncol(select(ingresos, starts_with("ing")))     # por cómo EMPIEZA el nombre
ncol(select(ingresos, where(is.numeric)))      # por el TIPO de contenido

# ✅ Deberías ver: 4 y 7

# 🔮 PREDICE: ¿por qué where(is.numeric) da 7 y no 4? Porque 7 contienen datos 
# numéricos y 4 empiezan por "ing".

names(select(ingresos, where(is.numeric)))

# ✅ Deberías ver que también entraron educ, edad y horas: son números, aunque
#    no sean ingresos. Los dos selectores NO son intercambiables.

# ✏️ COMPLETA: quédate con las columnas de TEXTO.
names(select(ingresos, where(is.character)))

# ✅ Deberías ver: region, sector, genero

# ⚠️ GOTCHA: elegir el selector equivocado NO da error. El código corre y
#    calcula sobre columnas que no querías. Es un error silencioso.


# -----------------------------------------------------------------------------
# BLOQUE B — filter(): elegir FILAS
# -----------------------------------------------------------------------------
# 🔵 CORRE Y OBSERVA
filter(casen, region == "Ñuble")
nrow(filter(casen, region == "Ñuble"))

# ✅ Deberías ver: 15 filas (los casos de Ñuble).

nrow(filter(casen, educ >= 16))
# ✅ Deberías ver: 12

# 🔮 PREDICE: ¿qué crees que hace la coma dentro de filter()? ¿O, o Y?
#    Escribe tu predicción aquí antes de correr: Selecciona dentro de casen.
nrow(filter(casen, region == "Ñuble", educ > 12))

# ✏️ COMPLETA: cuántas MUJERES ("F") hay en el sector "Servicios".
nrow(filter(casen, genero == "F", sector == "Servicios"))

# ⚠️ GOTCHA: == compara, = asigna. Y para texto SIEMPRE entre comillas.

# 🔵 CORRE Y OBSERVA — comparaciones muy útiles
nrow(filter(casen, region %in% c("Ñuble", "Biobío")))   # pertenece a la lista
nrow(filter(casen, is.na(ingreso)))                     # los que NO tienen dato
nrow(filter(casen, !is.na(ingreso)))                    # los que SÍ lo tienen

# ✅ Deberías ver: 25 ... 5 ... 55


# --- Combinar condiciones: & (Y) y | (O) -------------------------------------
# 🔵 CORRE Y OBSERVA
nrow(filter(ingresos, region == "Ñuble" & educ >= 16))    # las DOS cosas
nrow(filter(ingresos, region == "Ñuble" | region == "Biobío"))  # basta UNA

# ✅ Deberías ver: 3 y 25

# 💡 La coma dentro de filter() ES un &. Se escribe & explícito cuando hay que
#    mezclarlo con un |, porque ahí la coma ya no alcanza.
#    Para leerlas: & ACHICA el resultado (pide más); | lo AGRANDA (pide menos).

# 🔮 PREDICE: estas dos líneas se parecen mucho. ¿Dan el mismo número?
#    Anota tu predicción ANTES de correrlas: No.

nrow(filter(ingresos, (region == "Ñuble" | region == "Biobío") & educ > 12))
nrow(filter(ingresos, region == "Ñuble" | region == "Biobío" & educ > 12))

# ✅ Deberías ver: 10 y 20. ¡El doble!
#
# ⚠️ GOTCHA IMPORTANTE: & se evalúa ANTES que |, como la multiplicación antes
#    que la suma. Sin paréntesis, la segunda línea pregunta otra cosa:
#    "todo Ñuble, O los de Biobío con educ > 12". R no avisa: responde bien
#    una pregunta distinta.
#    REGLA: si mezclas & con |, pon paréntesis SIEMPRE.

# 🟢 TU TURNO: ¿cuántas personas reciben subsidios Y trabajan más de 40 horas?
nrow(filter(ingresos, ing_subsidios > 0 & horas > 40))

# ✅ Deberías ver: 14

# 🔮 PREDICE: ¿cuántas reciben subsidios Y ADEMÁS tienen ingreso del capital?
nrow(filter(ingresos, ing_subsidios > 0 & ing_capital > 0))

# ✅ Deberías ver: 0. Un resultado vacío también es una respuesta: en estos
#    datos son grupos que no se cruzan. Conviene mirarlo antes de asumir
#    que el código está malo.


# -----------------------------------------------------------------------------
# BLOQUE C — mutate(): crear COLUMNAS
# -----------------------------------------------------------------------------
# 🔵 CORRE Y OBSERVA
casen <- mutate(casen, ingreso_miles = ingreso / 1000)
head(casen$ingreso_miles, 3)

# ✅ Deberías ver: 520 467 NA   <- el NA se propaga, y eso es correcto.

# La variable estrella de la economía laboral: experiencia potencial de Mincer
# (los años que una persona pudo haber trabajado: edad, menos años de estudio,
#  menos los 6 años previos a entrar al colegio)
casen <- mutate(casen, experiencia = pmax(edad - educ - 6, 0))
head(casen$experiencia, 5)
summary(casen$experiencia)

# ✅ Deberías ver: 15 0 34 33 22 ... y una mediana de 27 años.

# 🔮 PREDICE: ¿por qué pmax() y no max()? Corre las dos y compara:
max(casen$edad - casen$educ - 6)
length(pmax(casen$edad - casen$educ - 6, 0))

# ✅ Deberías ver: max() devuelve UN número (53); pmax() devuelve 60 valores,
#    uno por persona. pmax() compara "en paralelo", elemento por elemento.
#    El 0 evita experiencias negativas (imposibles).

# ✏️ COMPLETA: crea una indicadora TRUE/FALSE de educación superior (13 años o más).
casen <- mutate(casen, superior = educ >= 13)
sum(casen$superior)

# 💡 sum() de una columna TRUE/FALSE cuenta los TRUE (recap Semana 3).


# -----------------------------------------------------------------------------
# BLOQUE C2 — case_when(): cuando las categorías son MÁS DE DOS
# -----------------------------------------------------------------------------
# `superior` solo sabe decir sí o no. Pero casi ninguna clasificación económica
# tiene dos casos: tramos de edad, quintiles, niveles educativos...
# case_when() recibe una lista de   condición ~ valor.

# 🔵 CORRE Y OBSERVA
casen <- mutate(casen,
                nivel_educ = case_when(
                  educ <  12 ~ "Sin media completa",
                  educ == 12 ~ "Media completa",
                  educ >  12 ~ "Superior"
                ))
table(casen$nivel_educ)

# ✅ Deberías ver: Media completa 7 | Sin media completa 23 | Superior 30

# 🔮 PREDICE: si BORRO la línea del medio (educ == 12), ¿qué pasa con esas
#    personas? ¿Da error, o algo peor? Anota tu predicción: No consideraría Media Completa.

incompleto <- mutate(casen,
                     prueba = case_when(
                       educ <  12 ~ "bajo",
                       educ >  12 ~ "alto"
                     ))
sum(is.na(incompleto$prueba))

# ✅ Deberías ver: 7   <- ¡NO da error! Las 7 personas con educ == 12 quedaron
#    en NA, en silencio. Este es el gotcha grande de case_when().

# 💡 LA SOLUCIÓN: cerrar con  TRUE ~ "..."  que significa "todo lo demás".

# ✏️ COMPLETA: tramos de edad. Cierra el case_when con TRUE.
casen <- mutate(casen,
                tramo = case_when(
                  edad < 30 ~ "joven",
                  edad < 45 ~ "adulto",
                  TRUE      ~ "mayor"
                ))
table(casen$tramo)

# ✅ Deberías ver: adulto 15 | joven 14 | mayor 31

# ⚠️ GOTCHA 2: se evalúa DE ARRIBA HACIA ABAJO y gana la PRIMERA condición que
#    se cumple. Por eso la segunda línea dice `edad < 45` a secas y no
#    `edad >= 30 & edad < 45`: los menores de 30 ya salieron en la línea previa.
#    Si pusieras `edad < 100` primero, TODOS caerían ahí.


# -----------------------------------------------------------------------------
# BLOQUE D — summarise(): COLAPSAR a un resumen
# -----------------------------------------------------------------------------
# 🔵 CORRE Y OBSERVA
summarise(casen, ingreso_promedio = mean(ingreso, na.rm = TRUE))

# ✅ Deberías ver: una tabla de 1 fila con 655290.9

# 🔮 PREDICE: ¿qué pasa si quito na.rm = TRUE? Predice antes de correr: Daría NA
mean(casen$ingreso)
mean(casen$ingreso, na.rm = TRUE)

# ✅ Deberías ver: NA en el primero. UN solo faltante contamina toda la operación.

# ✏️ COMPLETA: agrega la mediana del ingreso y el promedio de educación.
summarise(casen,
          n         = n(),
          ing_prom  = mean(ingreso, na.rm = TRUE),
          ing_med   = median(ingreso, na.rm = TRUE),
          educ_prom = mean(educ, na.rm = TRUE))

# ✅ Deberías ver: n = 60 | ing_prom = 655290.9 | ing_med = 672000 | educ_prom = 12.73

# 💡 HÁBITO PROFESIONAL: reportar SIEMPRE n() junto al promedio. Un promedio de
#    2 casos no vale lo mismo que uno de 20. Es honestidad analítica.


# -----------------------------------------------------------------------------
# BLOQUE E — El pipe |>: encadenar
# -----------------------------------------------------------------------------
# 👀 SOLO MIRA — sin pipe hay que anidar, y se lee de adentro hacia afuera:
summarise(filter(casen, region == "Ñuble"),
          ing = mean(ingreso, na.rm = TRUE))

# 🔵 CORRE Y OBSERVA — con pipe se lee como una receta:
#    "toma casen, Y LUEGO filtra Ñuble, Y LUEGO resume"
casen |>
  filter(region == "Ñuble") |>
  summarise(n = n(), ing = mean(ingreso, na.rm = TRUE))

# ✅ Deberías ver: n = 15 | ing = 696692.3   (el mismo número, pero legible)

# 🟢 TU TURNO: escribe una cadena que calcule el ingreso promedio y el n
#    de las personas con educ >= 16.
casen |>
  filter(educ >= 16) |>
  summarise(n = n(), ing = mean(ingreso, na.rm = TRUE))

# ✅ Deberías ver: n = 12 | ing = 812181.8

# 🟢 TU TURNO (desafío): los cinco verbos en una sola cadena.
#    Quita los NA, crea el ingreso en millones, quédate con 3 columnas y resume.
casen |>
  filter(!is.na(ingreso)) |>
  mutate(ing_millones = ingreso / 1e6) |>
  select(region, educ, ing_millones) |>
  summarise(n = n(), prom_millones = mean(ing_millones))

# ✅ Deberías ver: n = 55 | prom_millones = 0.655


# -----------------------------------------------------------------------------
# CIERRE — select (columnas) · filter (filas) · mutate (crear) ·
#          case_when (clasificar en 3+) · summarise (colapsar) · |> (encadenar).
# Puente Sesión 2: summarise() sobre toda la tabla da UN número.
#   ¿Y si quiero uno POR REGIÓN? -> group_by().
# =============================================================================
