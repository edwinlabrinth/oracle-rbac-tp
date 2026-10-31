# oracle-rbac-tp

TP « Sécurité : RBAC avec Oracle Database » — LACHHAB Mohammed, GINF2, ENSA Tanger (2026/2027).

## Livrables (dossier `deliverables/`)

Le dossier `deliverables/` contient tout ce qui est demandé pour le rendu du TP :

- `compte_rendu_LACHHAB_Mohammed.pdf` — compte rendu complet (tous les chapitres 0 à 6, commandes, résultats réels et réponses aux questions)
- `scripts/` — tous les scripts SQL commentés par exercice (y compris T1.sql à T7.sql pour l'étude de cas Banque Atlas)
- `screenshots/` — captures des sorties SQL*Plus réelles (format PNG)

## Télécharger uniquement le dossier `deliverables/`

GitHub ne propose pas de bouton « télécharger ce dossier » nativement. Voici trois méthodes pour récupérer **uniquement** le dossier `deliverables/` sans cloner tout le dépôt :

### Option 1 : avec `svn` (GitHub exposes les dépôts en SVN)
```bash
svn export https://github.com/edwinlabrinth/oracle-rbac-tp/trunk/deliverables
```

### Option 2 : avec `git` (sparse checkout)
```bash
git clone --filter=blob:none --sparse https://github.com/edwinlabrinth/oracle-rbac-tp.git
cd oracle-rbac-tp
git sparse-checkout set deliverables
```

### Option 3 : télécharger le dépôt entier (ZIP)
[https://github.com/edwinlabrinth/oracle-rbac-tp/archive/refs/heads/main.zip](https://github.com/edwinlabrinth/oracle-rbac-tp/archive/refs/heads/main.zip)

Puis extraire uniquement le dossier `deliverables/` depuis l'archive.

## Structure du dépôt

- `scripts/*.sql` — scripts SQL exécutés (chapitre 0 à 6)
- `logs/*.log` — journaux réels des sessions SQL*Plus
- `screenshots/*.png` — rendus des logs pour le rapport
- `report/chN.tex` — sections LaTeX du compte rendu
- `report/main.tex` — compilation du PDF
- `deliverables/` — dossier de rendu final (PDF + scripts + screenshots)
