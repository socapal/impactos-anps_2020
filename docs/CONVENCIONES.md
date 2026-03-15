# Convenciones del repositorio

## Principios generales
- `main` es la base documental y estable del repositorio general.
- Las extensiones analíticas o de producto viven en ramas temáticas.
- Evitar incluir datos sensibles en notas, logs o commits.

## Nomenclatura de ramas
- `paper-*`: manuscritos y su pipeline específico.
- `data-*`: procesos de datos y armonizaciones.
- `fig-*`: producción/iteración de visualizaciones.
- `infra-*`: automatización y estructura del repositorio.

## Convenciones de commits
- Mensajes claros con prefijo: `docs:`, `paper:`, `data:`, `analysis:`, `infra:`.
- Un commit debe representar una unidad lógica de cambio.
- Cada commit importante debe reflejarse en `docs/CHANGELOG_NARRATIVO.md` (3–6 bullets).

## Estructura recomendada
- Insumos originales: `datasets-brutas/`
- Datos transformados: `datos-procesados/`
- Scripts base: `parques-recreacion_código/`
- Documentación transversal: `docs/`
- Manuscritos: `paper/` (en ramas `paper-*`)

## Convenciones para memoria académica
- Registrar cada sesión en `docs/DIARIO_INVESTIGACION.md`.
- Registrar decisiones metodológicas/de datos en `docs/DECISION_LOG.md`.
- Mantener preguntas abiertas priorizadas en `docs/OPEN_QUESTIONS.md`.

## Convenciones del paper (LaTeX)
- Manuscrito principal en `paper/manuscript/main.tex`.
- Bibliografía de trabajo en `paper/bibliography/refs.bib`.
- Figuras y tablas en `paper/figures/` y `paper/tables/`.
- Scripts específicos del paper en `paper/code/` como wrappers sobre scripts base cuando sea posible.
