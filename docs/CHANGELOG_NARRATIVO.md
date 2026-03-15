# Changelog narrativo

Resumen humano de cambios por commit (complementario al `git log`).

## Reglas
- Cada commit importante agrega 3–6 bullets.
- Referenciar archivos y motivo del cambio.

## Entradas

### 2026-03-15 — docs: add repo README, repo map, and research memory logs
- Se reescribió `README.md` para posicionar el repositorio como base general de investigación y no únicamente como paper.
- Se agregó `MAPA_DEL_REPO.md` con árbol estructural, descripciones y rutas rápidas.
- Se creó utilidad opcional `scripts/utils/generate_repo_map.sh` para regenerar el mapa.
- Se fortalecieron plantillas de memoria manual académica en `docs/`.
- Se documentó explícitamente el manejo metodológico de la discontinuidad 2019 (core 2014–2018, 2019+ robustez).

### 2026-03-15 — paper: scaffold working paper structure and LaTeX template
- Se creó la estructura mínima de `paper/` para aislar el working paper del repositorio general.
- Se añadió `paper/README.md` con alcance, muestra, outcomes y reglas operativas.
- Se incorporó plantilla LaTeX inicial en `paper/manuscript/main.tex` con secciones estándar.
- Se agregaron carpetas de trabajo reproducible (`paper/code/`, `paper/output/`, `paper/figures/`, `paper/tables/`, `paper/notes/`).
- Se inicializó `paper/bibliography/refs.bib` y bitácora `paper/DIARIO_PAPER.md`.
