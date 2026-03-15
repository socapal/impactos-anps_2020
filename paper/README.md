# Working paper: sismos y bienestar local (2014m1–2018m12)

Esta carpeta contiene el desarrollo del working paper acotado en la rama `paper-sismos-2014-2019`.

## Alcance

- **Pregunta:** efectos de la cercanía a ANPs sobre indicadores de bienestar local.
- **Ventana core:** 2014m1–2018m12.
- **Ventana extendida:** 2019–2022 solo como complemento/robustez por discontinuidades de inventario y pandemia.

## Diseño empírico (resumen)

- **Tratamiento:** localidades dentro del área de influencia definida (radio operacional de referencia: 10 km) respecto a ANPs.
- **Control:** localidades comparables fuera del área de influencia en el esquema de matching.
- **Método principal:** Propensity Score Matching + estimaciones subsecuentes.

## Outcomes prioritarios

- Marginación
- Ingreso per cápita
- Acceso a servicios básicos

## Estructura de la carpeta

- `manuscript/`: texto del paper en LaTeX.
- `code/`: scripts específicos del paper (wrappers sobre scripts base del repo).
- `output/`: resultados reproducibles intermedios.
- `figures/`: figuras para manuscrito.
- `tables/`: tablas del manuscrito.
- `bibliography/`: referencias bibliográficas (`refs.bib`).
- `notes/`: notas metodológicas, apéndices de trabajo y pendientes.

## Reglas de trabajo

1. No mover ni editar fuentes originales sin registrar decisión en `docs/DECISION_LOG.md`.
2. Registrar avances de sesiones en `paper/DIARIO_PAPER.md`.
3. Evitar hardcodear rutas absolutas en scripts de `paper/code/`.
