#!/bin/bash
# Exécute un script SQL*Plus dans le conteneur Oracle, affiche et journalise TOUT
# (commandes echoées + résultats + erreurs) dans logs/<nom>.log
#
# Usage :
#   bash tools/sq.sh <nom_du_log> < scripts/1_1.sql
#   bash tools/sq.sh <nom_du_log> <<'SQL'
#   CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
#   SELECT USER FROM dual;
#   SQL
#
# Règles :
#  - la session démarre SANS connexion (/nolog) : le script doit contenir ses propres CONNECT
#  - les erreurs SQL n'arrêtent pas le script (voulu : on veut voir les ORA-xxxxx)
#  - le log est écrasé à chaque exécution
#  - pour lancer deux sessions en parallèle : ajouter & puis `wait`

NAME="${1:?Usage: bash tools/sq.sh <nom_du_log> < script.sql}"
mkdir -p logs
TMP="/tmp/run_$$_$RANDOM.sql"

{
  echo "SET ECHO ON FEEDBACK ON LINESIZE 120 PAGESIZE 50 SQLBLANKLINES ON TRIMSPOOL ON LONG 2000 SERVEROUTPUT ON"
  cat
  echo "EXIT"
} | docker exec -i oracle bash -c "cat > $TMP"

docker exec -e NLS_LANG=AMERICAN_AMERICA.AL32UTF8 oracle sqlplus /nolog @"$TMP" < /dev/null 2>&1 | tee "logs/$NAME.log"

docker exec oracle rm -f "$TMP"
