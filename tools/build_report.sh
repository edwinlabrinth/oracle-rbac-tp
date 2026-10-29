#!/bin/bash
# Compile report/main.tex -> report/main.pdf (xelatex, 2 passes) puis copie vers
# compte_rendu_LACHHAB_Mohammed.pdf à la racine. À lancer depuis la racine du dépôt :
#   bash tools/build_report.sh
for i in 1 2; do
  xelatex -interaction=nonstopmode -halt-on-error -output-directory=report report/main.tex > report/build.log 2>&1 || {
    echo "ERREUR LaTeX (pass $i). Lignes utiles :"
    grep -n -A6 '^!' report/build.log | head -40
    echo "(log complet : report/build.log)"
    exit 1
  }
done
cp report/main.pdf compte_rendu_LACHHAB_Mohammed.pdf && echo "PDF OK -> compte_rendu_LACHHAB_Mohammed.pdf"
