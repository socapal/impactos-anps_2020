#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUTPUT_FILE="$ROOT_DIR/MAPA_DEL_REPO.md"

cd "$ROOT_DIR"

{
  echo "# MAPA DEL REPOSITORIO"
  echo
  echo "## Árbol de directorios (2–4 niveles)"
  echo
  echo '```text'
  find . -maxdepth 4 -type d \
    | sed 's#^\./##' \
    | rg -v '^\.git($|/)' \
    | awk '
      BEGIN { FS="/" }
      {
        if ($0==".") { print "."; next }
        depth=NF-1
        indent=""
        for (i=0; i<depth; i++) indent=indent "│   "
        print indent "├── " $NF "/"
      }
    '
  echo '```'
  echo
  echo "## Qué vive en cada carpeta"
  echo
  echo "- Editar manualmente esta sección para descripciones actualizadas por carpeta."
  echo
  echo "## Rutas rápidas"
  echo
  echo "- Agregar/actualizar rutas clave de scripts, datos y outputs."
} > "$OUTPUT_FILE"

echo "MAPA_DEL_REPO.md generado en: $OUTPUT_FILE"
