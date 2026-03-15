# MAPA DEL REPOSITORIO

## Árbol de directorios (2–4 niveles)

```text
.
├── README.md
├── MAPA_DEL_REPO.md
├── LICENSE
├── anps.csv
├── docs/
│   ├── DIARIO_INVESTIGACION.md
│   ├── DECISION_LOG.md
│   ├── OPEN_QUESTIONS.md
│   ├── CHANGELOG_NARRATIVO.md
│   └── CONVENCIONES.md
├── datasets-brutas/
│   ├── dummies-cercanas.csv
│   ├── misc.xlsx
│   ├── agebs/
│   │   ├── _conjunto_de_datos/
│   │   ├── _metadatos/
│   │   └── _diccionario_de_datos/
│   └── shp/
│       ├── anps/
│       └── mun/
├── datos-procesados/
│   ├── tablas-r/
│   ├── datos.xlsx
│   └── summary.csv
├── parques-recreacion_código/
│   ├── 0. Procesamiento-datos.R
│   ├── 1. Estadística-descriptiva.R
│   ├── 2. Matching-Regresiones.r
│   └── 3. Visualizaciones-y-mapas.R
├── ilustraciones/
│   └── Ilustraciones-finales/
├── presentacion-final/
└── scripts/
    └── utils/
        └── generate_repo_map.sh
```

## Qué vive en cada carpeta

- `datasets-brutas/`: fuentes originales y metadatos de entrada.
- `datos-procesados/`: productos intermedios y tablas derivadas para análisis.
- `parques-recreacion_código/`: scripts principales del flujo analítico base.
- `ilustraciones/`: figuras de trabajo y versiones finales.
- `docs/`: memoria manual académica y reglas de trabajo.
- `paper/` (en ramas temáticas): estructura de manuscritos específicos.
- `scripts/utils/`: utilidades de mantenimiento del repositorio.

## Rutas rápidas

- Script de procesamiento base: `parques-recreacion_código/0. Procesamiento-datos.R`
- Script de matching/regresiones: `parques-recreacion_código/2. Matching-Regresiones.r`
- Datos de entrada: `datasets-brutas/`
- Outputs de análisis: `datos-procesados/` e `ilustraciones/`
- Memoria académica: `docs/DIARIO_INVESTIGACION.md`, `docs/DECISION_LOG.md`
- Convenciones: `docs/CONVENCIONES.md`

## Regenerar este mapa (opcional)

Usar:

```bash
bash scripts/utils/generate_repo_map.sh
```

El script genera un árbol de directorios y lo guarda en `MAPA_DEL_REPO.md` con una plantilla editable.
