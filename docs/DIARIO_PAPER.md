# Diario del paper
Bitácora corta específica del paper. Referencia cruzada con `docs/DIARIO_INVESTIGACION.md`.

## Template de entrada
- **Fecha:** YYYY-MM-DD
- **Commit (si aplica):** `hash`
- **Objetivo del paper:**
- **Cambios realizados (archivos):**
- **Resultados/figuras generadas:**
- **Pendientes (next):**
- **Notas:**

---
## Template de entrada
- **Fecha:** YYYY-MM-DD
- **Commit (si aplica):** `hash`
- **Objetivo del paper:**
- **Cambios realizados (archivos):**
- **Resultados/figuras generadas:**
- **Pendientes (next):**
- **Notas:**

-**Fecha:** 2026-03-07
-**Commit (si aplica):** to-do
-**Objetivo del paper:** Consolidar un flujo reproducible para cruzar inventario de vivienda y declaratorias de desastre a nivel municipio-mes, dejando preparada la infraestructura para diagnósticos y estimación con tratamiento escalonado.
-**Cambios realizados (archivos):**
- Ajustes de homologación en SeriesCENAPRED_Declaratorias.
- Ajustes de homologación en SeriesSNIIV_Inventario.R.
- Creación de 20260305_1_ConstruccionPanelMaster como script base para construir paneles integrados y servir como módulo maestro del pipeline.
- Definición inicial de un custom_theme de ggplot2 para estandarizar gráficas reproducibles.
-**Resultados/figuras generadas:** Aún no se generaron figuras finales; quedó preparada la estructura para producir paneles y salidas gráficas homologadas.
-**Pendientes (next):** 
- Construir la intersección declaratorias × inventario a nivel municipio-mes.
- Medir cobertura efectiva del inventario frente a eventos de desastre.
- Integrar en un solo flujo maestro los diagnósticos de Callaway usando 00_repro_callaway_abort.R, 01_diag_callaway_window.R, 20260203_1_AnalisisSismos_V03.R, 20251102_CAP2_AnalisisSismos_VF y 20251102_CAP2_Diagnostics.
- Afinar el custom_theme para uso consistente en productos del paper.
- **Notas:** Se privilegió limpieza, modularidad y trazabilidad del código. El theme sigue siendo provisional, pero ya permite una capa mínima de estandarización visual y refuerza la lógica de replicabilidad del proyecto. El flujo de trabajo de la investigación ya podría llegar a ejecutarse en forma de consultas si hacemos reproducible todo lo expresado en script master y ajustamos ese script para un flujo de trabajo de queries. 

- **Fecha:** 2026-03-03
- **Commit (si aplica)**: 4b4aae0f3303f46f8c0c78c3232b7c87793f0389
- **Fecha:** 2026-03-04
- **Commit (si aplica):** `PENDING`
- **Objetivo del paper:** Revisar el PR de declaratorias CENAPRED, homologar la redacción de bitácoras y dejar trazabilidad del enlace con el diagnóstico de inventario.
- **Cambios realizados (archivos):** Revisión de artefactos nuevos del PR (`decl_long_fen`, `decl_long_admin`, log de validadores y script de serie CENAPRED); homologación de entradas recientes en `paper/DIARIO_PAPER.md` y `docs/DIARIO_INVESTIGACION.md`; actualización de memoria institucional en `docs/DECISION_LOG.md`, `docs/OPEN_QUESTIONS.md` y `docs/CHANGELOG_NARRATIVO.md`.
- **Resultados/figuras generadas:** No se generaron figuras nuevas; se confirmó que el PR conserva salidas en formatos de texto (`.csv`/`.txt`) y no introduce binarios pesados adicionales.
- **Pendientes (next):**
  - Ejecutar la intersección `decl_long_fen × inventario` para medir cobertura efectiva municipio-mes.
  - Documentar explícitamente en el manuscrito la limitación de homologación del inventario (corte pre/post 2019).
  - Resolver gobernanza de archivos de sesión de R (`.Rhistory`) para evitar ruido en próximos PR.
- **Notas:**
  - Se incorporó el contexto del log `20260123_diagnostico_inventario.txt`: no es viable reconstruir retrospectivamente un stock homogéneo de inventario con el microdato de flujo disponible.
  - Se mantiene el alcance metodológico en fase descriptiva/diagnóstica, sin claims causales hasta validar soporte empírico conjunto.

- **Fecha:** 2026-03-03
- **Commit (si aplica):** `to-do`
- **Objetivo del paper:** Construir y documentar el panel de declaratorias CENAPRED compatible con el inventario de vivienda para evaluar cobertura territorial antes de especificar el modelo causal.
- **Cambios realizados (archivos):** Script de series y validadores de declaratorias (`20251014_0_SeriesCENAPRED_Decalaratorias.R`); generación de paneles derivados (`decl_long_fen`, `decl_long_admin`) y bloque de logging auditable al final del script.
- **Resultados/figuras generadas:** Serie mensual de declaratorias (diagnóstico exploratorio) y distribución por tipo de fenómeno para revisión interna. Registro completo de validadores y decisiones documentado en `logs/*validadores_declaratorias_cenapred.txt`.
- **Pendientes (next):** Integrar `decl_long_fen` con el panel municipal-mensual del inventario para construir el indicador de cobertura declaratorias × inventario. Preparar artefactos precomputados para tablero descriptivo.
- **Notas:**
  - Se documentó la lógica del panel de declaratorias en el log: motivación, periodo analítico y tratamiento de etiquetas compuestas.
  - Se definieron dos capas de datos: fenómeno (analítica) y administrativa (auditoría) para mantener trazabilidad del dato original.
  - El periodo analítico se acota a partir de 2015 por consistencia con el soporte del inventario.
  - Se observó alta volatilidad en la serie mensual; la media móvil sugiere comportamiento decreciente reciente. Interpretación institucional preliminar documentada como hipótesis en el log.

* **Fecha:** 2026-02-18
* **Commit (si aplica):** `to-do`
* **Objetivo del paper:** Corregir inconsistencia temporal en la asignación del tratamiento sísmico (g_trat) y estabilizar la ejecución del DID escalonado (Callaway & Sant’Anna).
* **Cambios realizados (archivos):** Ajuste en script de construcción de declaratorias sísmicas (`primer_sismo`) y revisión de panel municipal-mensual base (outcomes).
* **Resultados/figuras generadas:** Diagnóstico de distribución de cohortes (g_trat) consistente con ventana del panel; se elimina parcialmente la causa del colapso del modelo Callaway.
* **Pendientes (next):** Integrar base long/paneles finales en `Analisis_Sismos_V03.R` y validar que el modelo Callaway corra sin abortar sesión. Revisar filtros/subbases para estimación estable.
* **Notas:**
  * Se detectó que el panel outcomes cubre **2009-08 a 2018-12**, pero la base de declaratorias incluía eventos **2001-10 a 2022-09**, generando cohortes fuera de soporte. 
  * Se acotó explícitamente la ventana de declaratorias sísmicas a **2014-01 a 2018-12**, coherente con el marco empírico del paper. 
  * Esto eliminó colas artificiales en eventos relativos (e = t_num - g_trat) y corrigió la fuente estructural del colapso del modelo. 
  * Tabla posterior a ajuste (g_trat) documentada para referencia y sanity check. 
  * (16-02) Se trabajó sobre el proyecto `desastres.Rproy` y el script `20260203_0_SeriesSNIIV_DiasInventario_V02.R`, generando paneles municipal-mensual wide y base long (`base_master_mun_mensual_long`). 
  * Se identificó que al integrar subbases filtradas del modelo long en `Analisis_Sismos_V03.R`, el indicador de Callaway sigue colapsando la sesión (pendiente resolver). 

---

- **Fecha:** 2026-02-08
- **Commit (si aplica):** `e74358b`
- **Objetivo del paper:** Preparar el esqueleto LaTeX modular en inglés para el working paper.
- **Cambios realizados (archivos):** paper/manuscript/*, paper/README.md.
- **Resultados/figuras generadas:** N/A.
- **Pendientes (next):** Completar secciones con contenido, insertar tablas/figuras y validar compilación.
- **Notas:** Rama activa: `paper-sismos-2014-2018`.

- **Fecha:** 2026-02-19
- **Commit (si aplica):** `PENDING`
- **Objetivo del paper:** Revisar el PR de diagnóstico Callaway, asegurar convenciones y dejar memoria institucional.
- **Cambios realizados (archivos):** `C02S04C_Investigacion/Scripts/01_diag_callaway_window.R`; actualización de bitácoras en `paper/` y `docs/`.
- **Resultados/figuras generadas:** Script diagnóstico para ventana 2014-01 a 2018-12 con salidas en `logs/` (controles por tiempo, soporte por evento y corridas mínimas de factibilidad).
- **Pendientes (next):** Ejecutar script en entorno de R del equipo y adjuntar logs/dumps del crash nativo en Callaway para aislar causa.
- **Notas:** Codex revisó que no se agregaran binarios sensibles al PR y que el cambio no toca estructura LaTeX del manuscrito.
- **Nota de compatibilidad (2026-02-19):** Los gráficos diagnósticos en PNG quedaron fuera de VCS; el PR conserva evidencia en TXT/CSV y script reproducible.


- **Fecha:** 2026-02-21
- **Commit (si aplica):** `PENDING`
- **Objetivo del paper:** Revisar PR de estabilización DID, proponer estrategia inicial de panel y actualizar memoria institucional.
- **Cambios realizados (archivos):** `C02S04C_Investigacion/Scripts/20260203_0_SeriesSNIIV_DiasInventario_V02.R`; bitácoras en `paper/` y `docs/`.
- **Resultados/figuras generadas:** Se agregó pipeline modular para pre-panel `att_gt(panel=TRUE)` (filtros por ceros estructurales, regla `<6` meses, grilla municipio×mes 2014-01/2018-12 y exportables de cobertura).
- **Pendientes (next):** Ejecutar script con datos institucionales completos; contrastar regla de imputación de 0 intermedio contra alternativa con `NA`; decidir tratamiento final de municipios con baja cobertura.
- **Notas:**
  - Codex validó consistencia estructural del manuscrito LaTeX (sin cambios en `paper/manuscript/`).
  - No se detectó incorporación nueva de binarios/sensibles en este ajuste.
  - TODO: No hubo descripción de PR explícita disponible en repo; se infirió intención desde bitácoras del 2026-02-20.

- **Fecha:** 2026-02-21
- **Commit (si aplica):** `PENDING`
- **Objetivo del paper:** Revisar el PR con paneles municipales mensuales ya versionados y mejorar la legibilidad operativa del script maestro de análisis.
- **Cambios realizados (archivos):** `C02S04C_Investigacion/Scripts/20260203_1_AnalisisSismos_V03.R`; actualizaciones de memoria en `paper/DIARIO_PAPER.md` y `docs/*`.
- **Resultados/figuras generadas:** No se generaron nuevas figuras; se ordenaron rutas/salidas del script (`Datos/Paneles`, `logs`) y se aclararon bloques de diagnóstico (`diag_summary`, `diag_event_support`).
- **Pendientes (next):** Ejecutar corrida completa en entorno R del equipo para validar que las rutas relativas sean correctas y confirmar si el bloqueo de `att_gt` persiste con el panel `panel_mun_mensual_unidades_attgt_ready.csv`.
- **Notas:**
  - Autor: incorporó resultados de panel municipal mensual mediante commit `15a14a0` (CSV + logs de diagnóstico).
  - Codex: revisó estructura del PR (sin cambios en scaffold LaTeX), confirmó que los nuevos artefactos son texto liviano y no binarios, y corrigió claridad del script V03 sin alterar la estrategia empírica.
  - TODO: no hay descripción formal del PR en el repo; la intención se infirió desde commit y bitácoras.

- **Fecha:** 2026-02-22
- **Commit (si aplica):** `281f309`
- **Objetivo del paper:** Atender revisión del PR y crear versión LaTeX editable del deck de avances (enero 2026) a partir del PPTX institucional.
- **Cambios realizados (archivos):** Nuevo proyecto en `C02S04B_Presentaciones/20260121_C0S024_AvancesH1_Tesis_LaTeX/` (`main.tex`, `preamble.tex`, `slides/content.tex`, `README.md`, placeholders en `figures/` y `tables/`); actualización de bitácoras `paper/` y `docs/`.
- **Resultados/figuras generadas:** Deck Beamer con estructura slide-by-slide y placeholders para figuras/tablas del PPTX (sin alterar el PPTX original).
- **Pendientes (next):** Reemplazar placeholders por figuras finales; validar compilación en Overleaf y generar `deck.pdf` en entorno con LaTeX instalado.
- **Notas:**
  - Autor: dejó como referencia ejecutiva final el archivo `20260121_C0S024_AvancesH1_Tesis.pptx`.
  - Codex: reconstruyó el contenido textual del PPTX en formato Beamer editable y revisó consistencia del PR sin cambios en el manuscrito LaTeX del paper.
  - TODO: homologar terminología mensual/trimestral en resultados antes de próxima presentación.

- **Fecha:** 2026-02-23
- **Commit (si aplica):** `PENDING`
- **Objetivo del paper:** Cerrar revisión del PR de panel municipal y dejar una versión presentable del modelo teórico en LaTeX.
- **Cambios realizados (archivos):** `paper/manuscript/presentation_model.tex`, `paper/manuscript/README.md`, y actualización de memoria institucional en `paper/DIARIO_PAPER.md` + `docs/*`.
- **Resultados/figuras generadas:** Nueva presentación Beamer con el modelo (entorno, decisión dinámica, producción, extensión de seguro y vínculo empírico) lista para lectura/exposición.
- **Pendientes (next):** Validar en sesión de equipo si la presentación del modelo se integra como anexo de comité o como deck independiente; ejecutar una corrida institucional de `AnalisisSismos_V03.R` con paquete `did` fijado por versión.
- **Notas:**
  - Autor (PR): agregó paneles `att_gt` y logs de diagnóstico para trazabilidad metodológica.
  - Codex: revisó consistencia de estructura del paper, verificó que no se incorporaran secretos, y dejó documentación de decisiones/preguntas abiertas sin inventar resultados.
  - TODO: confirmar si los PNG de `C02S04C_Investigacion/logs/` deben permanecer versionados o migrar a artefactos externos para mantener el repo liviano.

- **Fecha:** 2026-03-02
- **Commit (si aplica):** `PENDING`
- **Objetivo del paper:** Revisar el pre-cierre de la rama de sismos 2014--2018, asegurar consistencia documental y dejar memo de cierre reproducible.
- **Cambios realizados (archivos):** `README_BRANCH.tex` (limpieza para compilación y secciones nuevas), `README_BRANCH.md` (espejo en Markdown), `docs/COMMIT_LEDGER.md` y actualización de diarios/logs en `paper/` y `docs/`.
- **Resultados/figuras generadas:** Memo de cierre con plan de promoción y criterios explícitos para reabrir DID de sismos; ledger de commits generado desde historial real del repo.
- **Pendientes (next):** Confirmar referencia local de la rama base `commit-inicial` para futura comparación automática; decidir qué paneles agregados deben permanecer versionados versus regenerarse bajo demanda.
- **Notas:**
  - Autor (PR previo): cerró provisionalmente la hipótesis causal de sismos 2014--2018 por problemas de soporte y composición.
  - Codex: validó estructura del scaffold LaTeX, revisó cambios del PR (`fa3ad3a..1895fbc`) y documentó hallazgos sin inventar resultados.
  - TODO: correr compilación de `README_BRANCH.tex` en entorno con `pdflatex` disponible para validar salida PDF final.

- **Fecha:** 2026-03-02
- **Commit (si aplica):** `PENDING`
- **Objetivo del paper:** Revisar cierre de la línea sísmica 2014--2018 y abrir scaffold de trabajo para `declaratorias-inventario` en modo descriptivo.
- **Cambios realizados (archivos):** Se creó `C02S04C_Investigacion/declaratorias-inventario/` con layout reproducible (scope, build, QC, mapas, perfiles, descriptivos de evento, sensibilidad y outputs); se corrigió formato pendiente en `docs/DIARIO_INVESTIGACION.md` y se actualizaron logs institucionales.
- **Resultados/figuras generadas:** No aplica (solo scaffold y contratos de salida `figure_XX_*`, `table_XX_*`).
- **Pendientes (next):** Implementar ingestas y construcción de panel municipio×mes 2014--2025; generar primero series de cobertura y tabla de conteos anual.
- **Notas:**
  - Autor (PR histórico): cerró provisionalmente DID de sismos por soporte limitado y composición inestable.
  - Codex: revisó diff disponible en rama local, confirmó ausencia de cambios LaTeX riesgosos en este PR y formalizó pivot metodológico a descriptivo-first sin claims causales.
  - TODO: localizar ref local de `commit-inicial` para automatizar comparación base→rama en revisiones futuras.

- **Fecha:** 2026-03-08
- **Commit (si aplica):** `PENDING`
- **Objetivo del paper:** Revisar el PR de rama `declaratorias_inventario`, aplicar fixes mínimos de coherencia ejecutable y dejar memoria institucional actualizada.
- **Cambios realizados (archivos):** ajustes mínimos en `C02S04C_Investigacion/Scripts/20260305_1_ConstruccionPanelMaster.R` y `20260307_Script_Analisis_Master.R`; nuevo helper `Scripts/helpers_plot_master_rec.R`; documentación metodológica breve en scripts `att_gt`; actualización de bitácoras `paper/` y `docs/`.
- **Resultados/figuras generadas:** Se dejó parametrizado el guardado estandarizado de figuras descriptivas (SNIIV y declaratorias) en `TablasFiguras/` con `dpi=300` desde el script maestro.
- **Pendientes (next):** Ejecutar corrida integral en entorno de datos institucionales para validar rutas relativas y confirmar intersección declaratorias × inventario con diagnósticos de cobertura temporal.
- **Notas:**
  - Codex confirmó estrategia metodológica por etapas: (1) un caso limpio con diagnósticos; (2) base para plataforma replicable posterior.
  - TODO: evaluar explícitamente el supuesto `coalesce(n_decl, 1L)` en declaratorias administrativas antes de congelar la definición de tratamiento.

- **Fecha:** 2026-03-08
- **Commit (si aplica):** `PENDING`
- **Objetivo del paper:** Aclarar integración funcional entre scripts Callaway y dejar un punto único de entrada para ejecución ordenada.
- **Cambios realizados (archivos):** Nuevo integrador `C02S04C_Investigacion/Scripts/20260308_0_CallawayPipeline_Master.R` y actualización de memoria institucional en `paper/` + `docs/`.
- **Resultados/figuras generadas:** No aplica (cambio de orquestación/documentación).
- **Pendientes (next):** Definir contrato único de outputs diagnósticos (`control_by_t`, `support_by_e`, `n_by_t`, `sessionInfo`) para converger iteraciones V03/CAP2.
- **Notas:** Se confirma lectura metodológica: `01_diag_callaway_window.R` es diagnóstico central de cobertura/soporte; `00_repro_callaway_abort.R` es depuración técnica de abortos; V03 y CAP2 son iteraciones complementarias.

- **Fecha:** 2026-03-08
- **Commit (si aplica):** `PENDING`
- **Objetivo del paper:** Revisar y aterrizar la presentación de tesis en LaTeX para revisión matutina, incorporando modelo teórico y descriptivos del panel maestro declaratorias-inventario.
- **Cambios realizados (archivos):** actualización de `slides/content.tex` y `slides/presentation_model.tex` en `C02S04B_Presentaciones/20260121_C0S024_AvancesH1_Tesis_LaTeX/`; refuerzo del script `C02S04C_Investigacion/Scripts/20260305_1_ConstruccionPanelMaster.R` para exportar figuras descriptivas priorizadas.
- **Resultados/figuras generadas:** nuevas figuras de cobertura por entidad, intersección inventario×declaratorias y event-study descriptivo preliminar; actualización de series SNIIV/declaratorias y distribución por fenómeno en `.../figures/`.
- **Pendientes (next):** correr el script R en entorno con `Rscript` disponible para validar exactamente los outputs desde el pipeline oficial y compilar PDF en entorno con TeX (`latexmk`/`pdflatex`).
- **Notas:**
  - Autor: pivot de narrativa desde “sismos como caso de estudio” hacia arquitectura de declaratorias + panel maestro municipio-mes.
  - Codex: revisó consistencia del flujo de slides, integró el modelo en español dentro del cuerpo principal y redujo claims causales no consolidados.
  - TODO: confirmar con asesor si la ventana de quiebre institucional debe fijarse en 2021-01 o en una fecha administrativa más precisa por instrumento.

- **Fecha:** 2026-03-08
- **Commit (si aplica):** `PENDING`
- **Objetivo del paper:** Corregir fallo del PR por incompatibilidad con binarios y mantener la PPT integrable sin adjuntar imágenes en el diff.
- **Cambios realizados (archivos):** `slides/content.tex` en la presentación para sustituir tres láminas por placeholders temporales; reversión/eliminación de PNG agregados/modificados en `.../figures/` para dejar el PR sin binarios nuevos.
- **Resultados/figuras generadas:** Se conserva la lógica de figuras en script, pero los assets binarios no se adjuntan en esta iteración del PR.
- **Pendientes (next):** Definir mecanismo de entrega de imágenes (artefactos externos/release/drive) y reinyectarlas antes de entrega final del deck compilado.
- **Notas:** Ajuste reactivo a comentario de revisión: "los archivos binarios no son compatibles en el pull request".

- **Fecha:** 2026-03-11
- **Commit (si aplica):** `PENDING`
- **Objetivo del paper:** Revisar el PR reciente del pipeline de análisis, centralizar funciones de figuras en helper y asegurar trazabilidad documental.
- **Cambios realizados (archivos):** Refactor de funciones ggplot hacia `C02S04C_Investigacion/Scripts/helper_scripts/helpers_plot_master_rec.R`; simplificación de `C02S04C_Investigacion/Scripts/20260305_1_ConstruccionPanelMaster.R` para dejar solo construcción/diagnóstico del panel; actualización de `C02S04C_Investigacion/Scripts/20260307_Script_Analisis_Master.R` para que replique las figuras finales vía helper y guarde en la ruta institucional acordada.
- **Resultados/figuras generadas:** No se agregaron figuras nuevas al repositorio; se dejó la replicación de figuras finales centralizada desde el script maestro de análisis.
- **Pendientes (next):**
  - Ejecutar corrida completa en entorno con R para validar generación end-to-end (faltó `Rscript` en este entorno).
  - Confirmar si se creará `docs/BITACORA.md` o se mantiene la bitácora en `docs/bitacora/`.
  - Revisar resultados de cobertura/intersección tras integrar AGEEML (nombres + abreviaciones) en panel y figuras.
- **Notas:**
  - Autor (PR): incorporó `AGEEML_20263102022475.csv`, ajustó panel maestro y regeneró artefactos LaTeX de presentación.
  - Codex: validó coherencia estructural del PR, detectó inclusión de binario grande (`main.pdf`) y dejó el flujo de figuras desacoplado en helper para mantener modularidad.
