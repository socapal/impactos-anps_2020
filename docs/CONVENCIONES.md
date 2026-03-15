# Convenciones del repositorio

## Estructura y nomenclatura
- `commit-inicial` es la base documental y estable.
- Ramas para productos: `paper-*` (papers), `data-*` (procesos de datos), `fig-*` (figuras/outputs).

## Commits
- Mensajes concisos y descriptivos.
- Prefijos sugeridos: `docs:`, `paper:`, `data:`, `analysis:`.

## Archivos y carpetas
- Evitar mover datasets grandes; usar rutas estables.
- Documentar scripts nuevos en README y/o logs.
- Mantener insumos originales separados de outputs.
- En scripts de análisis, declarar rutas de entrada/salida al inicio y guardar productos en carpetas de proyecto (evitar archivos sueltos en raíz).

## Reproducibilidad
- Scripts de paper deben vivir en `paper/code/`.
- Outputs reproducibles: `paper/output/`.
- Figuras y tablas: `paper/figures/` y `paper/tables/`.

## Convenciones del manuscrito (paper)
- Manuscrito modular en `paper/manuscript/` con `main.tex` + `preamble.tex` + `sections/*.tex` + `appendix/*.tex`.
- Etiquetas consistentes: `sec:*`, `subsec:*`, `tab:*`, `fig:*`, `eq:*`, `app:*`.
- Bibliografía del manuscrito: `paper/manuscript/references.bib` (copia de `paper/bibliography/refs.bib`).
- Figures y tables del manuscrito se guardan en `paper/manuscript/figures/` y `paper/manuscript/tables/`.
