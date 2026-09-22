# Laboratorio Semana 5 - Un análisis completo con dplyr

Actividad de laboratorio de la Semana 5 centrada en responder una pregunta 
económica de principio a fin utilizando los cinco verbos de dplyr, group_by() 
y el pipe, a partir de un subconjunto de la encuesta CASEN.

## Datos

Los datos utilizados corresponden a un subconjunto de la encuesta CASEN 
almacenado en:

`data/raw/casen_reducido.csv`
`data/raw/casen_ingresos.csv`

El primer archivo incluye información sobre región, sector económico, años de 
educación, edad, ingreso y género. El segundo contiene las mismas 60 personas, 
con el ingreso desagregado por fuente (trabajo, capital, subsidios).

## Cómo correrlo

1. Abrir `Repositorio_Sem5.Rproj`.
2. Abrir el script `scripts/semana5_lab_esqueleto.R`.
3. Ejecutar el script completo desde el inicio.

El script genera `data/processed/casen_s5_derivadas.csv` como salida.

## Estructura

```text

[Repositorio_Sem5]/
├── data/
│ ├── raw/
│ │   ├── casen_reducido.csv
│ │   └── casen_ingresos.csv
│ └── processed/
│     └── casen_s5_derivadas.csv
├── scripts/
│  ├── semana5_lab_esqueleto.R
│  ├── semana5_sesion1_guion
│  ├── semana5_sesion2_guion
├── Repositorio_Sem5.Rproj
├── README.md
├── .gitignore
└── .gitattributes

```

**Nota:** El desarrollo del laboratorio de la Semana 5 se encuentra en el 
script `scripts/semana5_lab_esqueleto.R`. Cualquier otro archivo dentro de 
`scripts/` corresponde a material de apoyo utilizado durante las sesiones 
de clase.

## Autor

Camila Bravo Figueroa — septiembre 2026