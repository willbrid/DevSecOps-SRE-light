#!/usr/bin/env bash
# Crée les fichiers du cours « Globs combinés » dont le nom contient
# *, ?, \ ou se termine par un point. Ces noms sont invalides sous Windows :
# ils ne sont donc pas versionnés dans git et sont générés par ce script.
set -euo pipefail

readonly WORK_DIR=$(dirname "$(readlink -f "$0")")

mkdir -p "${WORK_DIR}/exemple-1" "${WORK_DIR}/exemple-5" "${WORK_DIR}/exemple-6"

# Exemple 1 : nom terminé par un point
touch "${WORK_DIR}/exemple-1/file."

# Exemple 5 : étoile littérale dans les noms
cd "${WORK_DIR}/exemple-5"
touch 'R*al.py' 'f*a*il.txt' 'hail.doc' 'S*ail.txt' 'm*a?i*l.sh' '4ai*l.txt'

# Exemple 6 : séquence littérale \? dans les noms
cd "${WORK_DIR}/exemple-6"
touch 'file5\?xt' 'file_1234567\?890?xt' 'docA\?.docx' 'docZ.docx' 'rep1.txt'

echo "Fichiers créés dans exemple-1 (file.), exemple-5 et exemple-6."
