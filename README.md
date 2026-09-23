# T2 - Brecha de ingreso por tramo de edad en el sector Servicios

Tarea calificada de la Semana 5, que analiza si existe una brecha de ingreso 
entre distintos tramos de edad dentro del sector Servicios (el de mayor número 
de observaciones en la base), usando los cinco verbos de dplyr, group_by() y el pipe.

**Pregunta:** Dentro del sector Servicios, ¿existe una brecha de ingreso entre 
distintos tramos de edad? Si es que existe, ¿a cuánto equivale en pesos?

**Respuesta:** Sí existe una brecha. El tramo "mayor" tiene el ingreso 
promedio más alto ($830.000), seguido de "adulto" ($811.000) y "joven" 
($724.800) — una diferencia de $105.200 entre mayor y joven. Sin embargo, 
cada tramo cuenta con solo 5 observaciones, por lo que el resultado debe 
leerse como una observación puntual de esta muestra, no como un patrón 
generalizable.

## Datos

Los datos utilizados corresponden a un subconjunto de la encuesta CASEN 
almacenado en:

`data/raw/casen_reducido.csv`
`data/raw/casen_ingresos.csv`

El primer archivo incluye información sobre región, sector económico, años de 
educación, edad, ingreso y género. El segundo contiene las mismas 60 personas, 
con el ingreso desagregado por fuente (trabajo, capital, subsidios).

## Cómo correrlo

1. Abrir `Repsoitorio_Sem5.Rproj`.
2. Abrir el script `scripts/tarea_t2.R`.
3. Ejecutar el script completo desde el inicio.

## Estructura

```text

[Repositorio_Sem5]/
├── data/
│ └── raw/
│     ├── casen_reducido.csv
│     └── casen_ingresos.csv
│ └── processed/
│     └── casen_s5_derivadas.csv
├── scripts/
│ ├── semana5_lab_esqueleto.R
│ ├── semana5_sesion1_guion.R
│ ├── semana5_sesion2_guion.R
│ └── tarea_t2.R
├── Repositorio_Sem5.Rproj
├── README.md
├── .gitignore
└── .gitattributes

```
**Nota**:  El desarrollo de la T2 se encuentra en el script scripts/tarea_t2.R.
Cualquier otro archivo dentro de scripts/ corresponde a material de apoyo utilizado 
durante las sesiones de clase, al igual que los datos procesados en la carpeta 
data/processed.

## Autor

Camila Bravo Figueroa — septiembre 2026

## Declaración de autoría y uso de IA
- Herramienta utilizada: Claude Sonnet 5
- Para qué la usé: Para entender la utilización de cada uno de los códigos 
                   utilizados en el desarrollo de la tarea T2 para entender cómo 
                   tributaban a responder mi pregunta.
- Qué hice yo: Escribí los códigos en base a lo trabajado en el laboratorio de 
               la semana 5, adaptándolo a lo que pudiera utilizar en mi análisis.
- Verificación: confirmo que entiendo y puedo explicar todo lo que entrego.

