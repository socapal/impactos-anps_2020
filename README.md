# Impactos de ANPs en bienestar local (México)

Repositorio general de investigación para documentar, organizar y hacer replicable el análisis sobre externalidades económicas de las Áreas Naturales Protegidas (ANPs) en México. Este repositorio **no es solo un paper**: es la base documental y técnica para extensiones futuras (nuevas ventanas temporales, outcomes y estrategias empíricas).

## Propósito del repositorio

- Documentar de forma clara la investigación original y su lógica empírica.
- Organizar código, datos y productos intermedios/finales.
- Mantener una versión simplificada y replicable del argumento principal.
- Servir como base para nuevas líneas de trabajo de Refugio Económico.

## Qué contiene (visión de alto nivel)

- `datasets-brutas/`: insumos originales (geográficos, censales y auxiliares).
- `datos-procesados/`: tablas y objetos derivados del procesamiento.
- `parques-recreacion_código/`: scripts base de limpieza, descriptiva, matching, regresiones y visualización.
- `ilustraciones/`: figuras y materiales gráficos.
- `docs/`: memoria manual académica, convenciones y bitácoras narrativas.
- `paper/` (en ramas `paper-*`): estructura acotada para manuscritos específicos.

## Cómo navegar rápidamente

1. **Punto de entrada analítico**: `parques-recreacion_código/0. Procesamiento-datos.R`.
2. **Descriptiva y preparación para estimación**: `1. Estadística-descriptiva.R`.
3. **Estrategia principal (PSM + regresiones)**: `2. Matching-Regresiones.r`.
4. **Visualizaciones y mapas**: `3. Visualizaciones-y-mapas.R`.
5. **Memoria y decisiones**: `docs/`.

Para una guía estructural adicional, ver `MAPA_DEL_REPO.md`.

## Qué NO es este repositorio

- No es únicamente el entregable de un manuscrito.
- No está limitado a una sola especificación o ventana temporal.
- No sustituye el control de versiones por ramas temáticas.

## Principios de versionado

- `main`: base estable/documental del repositorio general.
- `paper-*`: ramas para manuscritos acotados (ej. `paper-sismos-2014-2019`).
- `data-*`: cambios mayores de construcción/armonización de datos.
- `fig-*`: iteraciones de visualización y reportes gráficos.

## Pipeline mínimo de reproducción (resumen)

> Ajustar rutas locales al inicio de cada script antes de correr.

1. Ejecutar `parques-recreacion_código/0. Procesamiento-datos.R` para preparar insumos analíticos.
2. Ejecutar `parques-recreacion_código/1. Estadística-descriptiva.R` para validación descriptiva.
3. Ejecutar `parques-recreacion_código/2. Matching-Regresiones.r` para estimación principal.
4. Ejecutar `parques-recreacion_código/3. Visualizaciones-y-mapas.R` para outputs gráficos.
5. Revisar `datos-procesados/`, `ilustraciones/` y registrar sesión en `docs/DIARIO_INVESTIGACION.md`.

## Nota metodológica sobre discontinuidad 2019

Por cambios en inventarios/levantamiento y el choque de pandemia, el núcleo analítico recomendado se concentra en **2014m1–2018m12**. El periodo **2019+** debe tratarse como extensión complementaria de robustez, documentando explícitamente supuestos de comparabilidad y sensibilidad.

## Privacidad y manejo de información

- Mantener el repositorio privado.
- Evitar incluir datos sensibles o identificadores personales en documentos de texto o logs.
