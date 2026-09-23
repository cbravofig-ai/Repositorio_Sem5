# =============================================================================
# T2 — Limpieza y agregación con dplyr
#
# Autor: Camila Bravo Figueroa
# Fecha: 22-09-2026
# Descripción: Analiza si existe una brecha de ingreso entre distintos tramos
#              de edad dentro del sector Servicios (el de mayor número de
#              observaciones en la base), usando los cinco verbos de dplyr,
#              group_by() y el pipe.
# =============================================================================

library(dplyr)   # carga el paquete que trae los verbos de manipulación de datos 
                 # (filter, mutate, group_by, etc.)

# -----------------------------------------------------------------------------
# PASO 1: Pregunta objetivo
# -----------------------------------------------------------------------------

# Dentro del sector Servicios, ¿existe una brecha de ingreso entre distintos 
# tramos de edad?. Si es que existe, ¿a cuánto equivale en pesos?

# Pregunta secundaria: ¿esa brecha por tramo de edad se ve distinta entre 
# hombres y mujeres dentro de Servicios?

# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# PASO 2: Carga y exploración de datos
# -----------------------------------------------------------------------------

casen    <- read.csv("data/raw/casen_reducido.csv")   # carga la base principal
ingresos <- read.csv("data/raw/casen_ingresos.csv")   # carga datos complementarios

table(casen$sector)         # contea los datos por sector, para verificar que  
                            # servicios sea el sector con el mayor número de 
                            # datos (17)

str(casen)                  # Explora la estructura y el tipo de datos de cada 
                            # columna para saber con que datos se está trabajando.

dim(casen)                  # Muestra la dimensión de la base de datos para 
                            # conocer el número de filas y columnas (60 x 6)

summary(casen$ingreso)      # Genera un resumen estadístico de la variable ingreso 
                            # en la base de datos, para mostrar su media, mediana, 
                            # mínimo, máximo, etc. Además, arroja la cantidad de 
                            # NAs presentes en la columna.

sum(is.na(casen$ingreso))   # Cuenta la cantidad específica de NAs presentes en 
                            # la columna de ingresos (5).

# EXPLORACIÓN DE DATOS:

# 1. La base de datos casen con 60 observaciones (filas) y 6 variables (columnas).
# 2. Las columnas región, sector, y genero tienen tipo de dato caracter (chr), 
#    mientras que las columnas educ,edad e ingreso tienen tipo de dato numérico 
#    entero (int).
# 3. La columna ingreso presenta 5 NAs reportados con la función summary() y 
#    sum(is.na()).

# -----------------------------------------------------------------------------
# PASO 2b: Selección de columnas por patrón
# -----------------------------------------------------------------------------

names(select(ingresos, starts_with("ing")))   # Selecciona las columnas cuyo nombre 
                                              # comience con "ing" (4).

names(select(ingresos, where(is.numeric)))    # Selecciona las columnas que 
                                              # contengan tipo de dato numerico (7).

# El selector por nombre arroja 4 columnas porque selecciona específicamente las 
# que comiencen con "ing" ("ing_trabajo", "ing_capital", "ing_subsidios", 
# "ing_total"). Mientras que el selector por tipo de dato numérico selecciona todas 
# las que contengan números en sus observaciones, independiente de su nombre, por 
# lo que incluye también las columnas educ, edad y horas.
#
# Estos selectores se utilizan para verificar con qué columnas se desea 
# trabajar y evitar seleccionar las equivocadas sin darse cuenta. Por eso es 
# importante definir si se quiere trabajar por nombre (starts_with) o por tipo 
# de dato (where).

# -----------------------------------------------------------------------------
# PASO 3: Utilización de los verbos para el análisis
# -----------------------------------------------------------------------------

# Primero, para revisar la distribución de edad (mínimo y máximo) solo dentro 
# del sector Servicios y así definir tramos con sentido, se utilizó:
summary(filter(casen, sector == "Servicios")$edad)  

# Luego, para contar cuántas personas quedan en cada uno de los tramos de edad 
# se utilizó:
nrow(filter(casen, sector == "Servicios", edad < 35)) 
nrow(filter(casen, sector == "Servicios", edad >= 35 & edad < 50))  
nrow(filter(casen, sector == "Servicios", edad >= 50))    

# -----------------------------------------------------------------------------
# Para la creación de nuestras nuevas columnas con tramo de edad y experiencia 
# potencial laboral (Mincer), se utiliza:
casen <- casen |>
  mutate(
    # Primero, para agregar la columna de tramo de edad definida por la exploración.
    # Se envuelve en factor() para que los tramos queden ordenados de forma lógica 
    # (joven, adulto, mayor) y no alfabética (adulto, joven, mayor).
    tramo_edad = factor(
      case_when(
        edad < 35 ~ "joven",
        edad < 50 ~ "adulto",
        TRUE      ~ "mayor"
      ),
      levels = c("joven", "adulto", "mayor")
    ),
    # Luego, para agregar la columna experiencia potencial (Mincer) se resta la 
    # edad, la educación y la edad típica de inicio escolar (6). Se compara ese 
    # resultado con 0 usando pmax(), para que si da negativo, quede en 0 en vez 
    # de un valor sin sentido.
    experiencia = pmax(edad - educ - 6, 0)   
  )

# Se revisa que tramo_edad no tenga NA: si el case_when() tuviera algún hueco, 
# no daría error, solo dejaría a esa persona sin clasificar sin que se note.
table(casen$tramo_edad, useNA = "ifany")

# RESULTADO: joven = 19, adulto = 15, mayor = 26. Sin columna <NA>, por lo 
# que las 60 personas quedaron clasificadas correctamente.

# Se revisa que experiencia no tenga negativos, para confirmar que el pmax() 
# hizo su trabajo (nadie puede tener experiencia negativa).
summary(casen$experiencia)

# RESULTADO: rango de 0 a 53 años, mediana 27. Sin valores negativos, por lo 
# que el pmax(..., 0) funcionó como se esperaba.

# Se confirma que los tramos calculados para toda la base siguen dando 5/6/6 
# al filtrar solo Servicios, igual que en la exploración inicial.
table(filter(casen, sector == "Servicios")$tramo_edad)
# RESULTADO: joven = 5, adulto = 6, mayor = 6 (total 17, coincide con el 
# número de personas de Servicios).

# -----------------------------------------------------------------------------
# Se filtran solo las personas del sector Servicios y con ingreso registrado 
# (sin NA), porque la pregunta es específicamente sobre ese sector y promediar 
# sobre datos faltantes no es correcto.
casen_servicios <- casen |>
  filter(sector == "Servicios" & !is.na(ingreso))

# Reducción a las columnas necesarias para el análisis de la pregunta: 
# tramo de edad, ingreso, y genero (para la agregación cruzada más adelante).
casen_servicios <- casen_servicios |>
  select(region, sector, tramo_edad, edad, genero, ingreso, experiencia)

# -----------------------------------------------------------------------------
# Primera agregación: ingreso promedio por tramo de edad dentro de Servicios.
# Esto responde directamente la pregunta principal: si existe una brecha entre 
# tramos y a cuánto equivale.
resumen_tramo <- casen_servicios |>
  group_by(tramo_edad) |>
  summarise(
    n = n(),
    ingreso_promedio = mean(ingreso, na.rm = TRUE)
  ) |>
  arrange(desc(ingreso_promedio))

resumen_tramo

# RESULTADO: mayor = $830.000 (n=5), adulto = $811.000 (n=5), 
# joven = $724.800 (n=5).

#------------------------------------------------------------------------------
# Nota: antes del filtro, Servicios tenía 5/6/6 personas por tramo (joven/adulto/
# mayor). Después de sacar los NA de ingreso, quedó en 5/5/5 — se perdió 1 
# persona en adulto y 1 en mayor. Esas 2 personas eran parte de los 5 NA totales 
# que tiene la columna ingreso en toda la base.
# -----------------------------------------------------------------------------

# Segunda agregación: ingreso promedio cruzando tramo de edad y género, 
# dentro de Servicios. Permite ver si la brecha por edad se comporta igual 
# en ambos géneros o no (pregunta secundaria).
resumen_tramo_genero <- casen_servicios |>
  group_by(tramo_edad, genero) |>
  summarise(
    n = n(),
    ingreso_promedio = mean(ingreso, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(desc(ingreso_promedio))

resumen_tramo_genero

# RESULTADO: el grupo con mayor ingreso promedio es mayor/F ($840.000), 
# pero con n=1 — un solo dato, no representativo. El resto de los grupos 
# tiene entre n=2 y n=4, también bajo el mínimo de 8 sugerido. Esta 
# agregación cruzada es más frágil que la anterior y se usa con cautela 
# en la interpretación final.

#------------------------------------------------------------------------------
# Nota: dado que todos los grupos de esta tabla tienen n muy pequeño 
# (entre 1 y 4), los resultados de la pregunta secundaria (brecha por 
# género dentro de cada tramo) deben tomarse solo como referencia y no 
# como un hallazgo sólido. Un solo caso puede cambiar por completo el 
# promedio de un grupo.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# PASO 4: Comparación individual con group_by() + mutate()
# -----------------------------------------------------------------------------

# A diferencia de summarise() (que colapsa la tabla a una fila por grupo), 
# aquí se usa mutate() después de group_by() para conservar las 15 filas 
# originales (personas de Servicios sin NA) y agregarles una columna que 
# las compara con el promedio de su propio tramo de edad. Esto responde 
# algo que resumen_tramo no puede: no solo cuánto gana el tramo en promedio, 
# sino qué tan lejos está cada persona de ese promedio.
casen_servicios <- casen_servicios |>
  group_by(tramo_edad) |>
  mutate(brecha_individual = ingreso - mean(ingreso, na.rm = TRUE)) |>
  ungroup()

# Se muestran las columnas relevantes para revisar el resultado: cada persona 
# con su tramo, su ingreso, y qué tan por sobre o bajo el promedio de su 
# tramo está.
casen_servicios |>
  select(tramo_edad, genero, ingreso, brecha_individual) |>
  arrange(brecha_individual)

# RESULTADO: la brecha individual va desde -$190.800 (un hombre joven que 
# gana bastante menos que el promedio de su tramo) hasta +$143.000 (una 
# mujer adulta que gana bastante más que el promedio del suyo). Dentro de 
# cada tramo hay harta dispersión: no todas las personas del mismo tramo 
# ganan parecido, el promedio del tramo esconde esas diferencias internas.
#
# Nota: esto es justo lo que summarise() no puede mostrar. resumen_tramo 
# dice que el promedio de "joven" es $724.800, pero acá se ve que dentro 
# de ese tramo hay desde alguien a -$190.800 del promedio hasta alguien a 
# +$99.200. group_by()+mutate() permite ver esa variación persona por 
# persona, en vez de perderla en un solo número.

# -----------------------------------------------------------------------------
# PASO 5: Tratamiento explícito de los NA
# -----------------------------------------------------------------------------

# Se compara el promedio de ingreso con y sin na.rm, para dejar en evidencia 
# qué pasa si no se tratan los NA explícitamente.
#
# Nota: se usa casen (la base completa) y no casen_servicios, porque en 
# casen_servicios los NA ya fueron eliminados por el filter() del Paso 3. 
# El contraste solo se nota donde todavía quedan valores faltantes.
mean(casen$ingreso)                    # sin na.rm
mean(casen$ingreso, na.rm = TRUE)      # con na.rm

# RESULTADO: sin na.rm el resultado es NA — basta con que exista un solo 
# valor faltante para que R no pueda calcular el promedio y devuelva NA 
# para todo el cálculo, no solo para esa fila. Con na.rm = TRUE, R ignora 
# los 5 NA y calcula el promedio con los 55 casos restantes, dando $655.291.
#
# Se pierden 5 de 60 casos. Es aceptable perderlos porque no hay forma de saber 
# qué ingreso tenían esas personas sin inventar un valor, y es una proporción 
# baja del total. Pero perder información implicaría que si esos 5 casos no 
# fueran aleatorios  el promedio de $655.291 podría estar sesgado.

# -----------------------------------------------------------------------------
# PASO 6: Encadenamiento con el pipe
# -----------------------------------------------------------------------------

# El pipe (|>) ya se usó en varios bloques anteriores, por ejemplo en 
# resumen_tramo y resumen_tramo_genero (Paso 4), donde se encadenan 3 o más 
# verbos seguidos: group_by() |> summarise() |> arrange().

# -----------------------------------------------------------------------------
# PASO 7: Interpretación
# -----------------------------------------------------------------------------

# INTERPRETACIÓN:
# En el sector Servicios se presentan brechas específicas para cada tramo de 
# edad: entre el tramo adulto y joven se presenta una brecha de $86.200, 
# entre adulto y mayor una brecha considerablemente menor de $19.000, y entre 
# joven y mayor la brecha más grande, de $105.200. Esto podría asociarse a  
# factores como la experiencia, el nivel de educación u otras variables no 
# consideradas, cuyo efecto particular debería evaluarse para saber la razón 
# específica de las brechas en el sector. Sin embargo, la cantidad de datos es 
# menor a 8, lo cual podría afectar el promedio de los ingresos a través de datos 
# atípicos: bastaría con que alguna de las personas de cada tramo gane 
# desproporcionadamente más para que esta brecha se dispare.
#
# Por otro lado, respecto de la pregunta secundaria (si la brecha por edad se 
# ve distinta entre hombres y mujeres), el grupo con mayor ingreso promedio 
# resultó ser mayor/F ($840.000), pero con apenas 1 persona. La cual se ve 
# aún más limitada por el número de personas filtradas, reducido a grupos de 
# entre 1 y 4 personas al cruzar tramo de edad con género, muy por debajo 
# del mínimo de 8 sugerido, por lo que estos resultados no son concluyentes.
#
# LIMITACIÓN: cada tramo de edad quedó con solo 5 observaciones (de 17 
# originales en Servicios, se perdieron 2 por tener NA en ingreso), y el 
# cruce con género queda aún más chico. Estos resultados deben leerse como 
# una observación puntual de esta muestra, no como un patrón generalizable 
# al sector Servicios en general.

# -----------------------------------------------------------------------------
# NOTA COMPLEMTARIA: exploración de una condición combinada más restrictiva
# -----------------------------------------------------------------------------

# Antes de definir el filtro final, se evaluó si tenía sentido acotar también 
# por región, cruzando sector con region usando & y |. Se prueba primero solo 
# con Ñuble, y luego ampliando a Ñuble o Biobío, en ambos casos con y sin 
# paréntesis para mostrar cómo cambia la interpretación de la condición.

# Intento 1: sector Servicios Y región Ñuble.
nrow(filter(casen, sector == "Servicios" & region == "Ñuble"))

# Intento 2: sector Servicios Y (región Ñuble O Biobío), con paréntesis.
nrow(filter(casen, sector == "Servicios" & (region == "Ñuble" | region == "Biobío")))

# Mismo intento 2, pero SIN paréntesis, para mostrar el efecto de mezclar 
# & con | sin delimitar: sin paréntesis, R evalúa primero el &, es decir 
# (region == "Ñuble" & region == "Biobío"). Como ninguna persona puede 
# pertenecer a dos regiones a la vez, esa parte siempre es falsa, por lo 
# que la condición completa termina dependiendo solo del |, es decir, solo 
# de sector == "Servicios". El resultado es idéntico al filtro sin 
# ninguna restricción de región, lo que confirma que sin paréntesis la 
# condición no hace lo que parecía pedir.
nrow(filter(casen, sector == "Servicios" | region == "Ñuble" & region == "Biobío"))

# Tras ver los resultados (Intento 1: 6 personas; Intento 2: 9 personas), se 
# optó por mantener el filtro solo por sector (Servicios, 17 personas), sin 
# restricción adicional de región. Si bien el Intento 2 superaba el mínimo 
# de 8 observaciones en total, al dividirlo en los tres tramos de edad los 
# grupos habrían quedado aún más chicos que los actuales (n=5 por tramo). 
# De todas formas, esta exploración permite demostrar el uso de condiciones 
# combinadas con & y | y el efecto del paréntesis.

# -----------------------------------------------------------------------------

