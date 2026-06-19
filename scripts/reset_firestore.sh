#!/usr/bin/env bash
# Borra todas las colecciones de Firestore del proyecto.
# Los usuarios de Firebase Authentication deben eliminarse desde la consola:
# https://console.firebase.google.com/project/arrienda-seguro-d3d45/authentication/users

set -euo pipefail

PROJECT="${FIREBASE_PROJECT:-arrienda-seguro-d3d45}"
COLLECTIONS=(
  "chat_rooms"
  "payments"
  "contracts"
  "rental_requests"
  "properties"
  "users"
)

echo "Proyecto: $PROJECT"
echo "Se eliminarán las colecciones: ${COLLECTIONS[*]}"
echo ""

for collection in "${COLLECTIONS[@]}"; do
  echo "→ Eliminando $collection (recursivo)..."
  firebase firestore:delete "$collection" \
    --recursive \
    --project "$PROJECT" \
    --force
done

echo ""
echo "✔ Firestore vacío."
echo ""
echo "IMPORTANTE: Elimina también los usuarios en Firebase Authentication:"
echo "  Console → Authentication → Users → seleccionar todos → Delete"
echo "  https://console.firebase.google.com/project/$PROJECT/authentication/users"
