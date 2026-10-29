# MISSION

Réaliser le TP « Sécurité : RBAC avec Oracle Database » (énoncé dans `tp.txt`) sur la VRAIE base,
puis produire le compte rendu en PDF (LaTeX). Étudiant : LACHHAB Mohammed, GINF2, ENSA Tanger.
Langue du rapport et des commentaires SQL : FRANÇAIS. Le rapport n'est pas un résumé : pour chaque
exercice il contient les commandes, les résultats réels (images) et les réponses aux questions.

# AU DÉMARRAGE DE CHAQUE SESSION (et après toute perte de contexte)

1. Lis ce fichier, puis `PROGRESS.md` (état d'avancement + mots de passe actuels).
2. Lis la section de `PLAYBOOK.md` qui correspond au chapitre en cours (pièges et pistes).
3. Lis l'énoncé du chapitre PAR MORCEAUX, jamais tout `tp.txt` d'un coup :
   `grep -n "Exercice" tp.txt` puis `sed -n 'DEBUT,FINp' tp.txt`.

# ENVIRONNEMENT (≠ énoncé)

- Oracle AI Database 26ai Free (23.26) dans le conteneur Docker `oracle`. PAS du 19c.
- La PDB s'appelle **FREEPDB1** (l'énoncé dit ORCLPDB : toujours remplacer).
- SYS : `CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA`
- Autre utilisateur : `CONNECT lina/"Lina#2026"@//localhost/FREEPDB1` (mot de passe TOUJOURS entre guillemets doubles)
- Proxy : `CONNECT dev1[rh]/"Dev1#2026"@//localhost/FREEPDB1`
- Racine CDB$ROOT (exercice 1.5 seulement) : `CONNECT / AS SYSDBA` puis `SHOW CON_NAME`
- Ne JAMAIS exécuter `scripts/99-nettoyage.sql` avant d'avoir tout terminé.

# OUTILS (tout est déjà écrit, ne les réécris pas)

- `bash tools/sq.sh <id> < scripts/<id>.sql` : exécute le script dans le conteneur, affiche et écrit `logs/<id>.log`
  (commandes echoées + résultats + erreurs). Le script contient ses propres `CONNECT`. Les erreurs ORA- ne
  l'arrêtent pas (voulu). Ne jamais utiliser `docker exec -it` (pas de terminal interactif pour toi).
- `python3 tools/shot.py logs/<id>.log "Exercice X.Y -- titre"` : produit `screenshots/<id>_N.png` et
  `screenshots/<id>.tex`.
- `bash tools/build_report.sh` : compile `report/main.tex` -> `compte_rendu_LACHHAB_Mohammed.pdf`.
- Dépendances (LaTeX, Pillow) : `bash tools/install_deps.sh` (l'étudiant l'a normalement déjà lancé).
- Lignes SQL*Plus : garde chaque ligne de sortie ≤ 120 caractères avec `COLUMN x FORMAT A20`,
  sinon l'image est illisible.

# BOUCLE DE TRAVAIL (pour CHAQUE exercice, dans l'ordre du TP)

1. Lis l'énoncé de l'exercice (sed -n sur tp.txt).
2. Écris `scripts/<id>.sql`, commenté en français (id = `1_1`, `1_2`, `2_3`... ; si plusieurs sessions
   parallèles : `4_1_a`, `4_1_b`).
3. Exécute : `bash tools/sq.sh <id> < scripts/<id>.sql`
4. LIS le log en entier. Compare avec le résultat attendu (codes ORA- listés dans les « Points de contrôle »
   de l'énoncé). Si ça diffère : ne bidouille pas la sortie, comprends pourquoi (voir « Écarts 26ai » plus bas),
   corrige ton script ou documente l'écart.
5. `python3 tools/shot.py logs/<id>.log "Exercice X.Y -- titre"`
6. Ajoute la section de l'exercice dans `report/chN.tex` (modèle ci-dessous).
7. Coche l'exercice dans `PROGRESS.md` et note les changements d'état (mots de passe, objets créés/supprimés).
8. À la fin du chapitre : `bash tools/build_report.sh` (doit afficher « PDF OK »), puis
   `git add -A && git commit -m "chapitre N"`. Puis ARRÊTE-TOI et fais un résumé (écarts, problèmes).
   Ne commence pas le chapitre suivant sans accord.

# RÈGLES ABSOLUES

1. Exécute chaque commande pour de vrai. N'INVENTE, ne devine, ne « reconstitue » JAMAIS une sortie, un code
   d'erreur, une date ou un nombre. Si une commande n'a pas été exécutée, elle n'est pas dans le rapport.
2. Les réponses aux questions « pourquoi / expliquez / que se passe-t-il » doivent s'appuyer sur ce que tu as
   observé dans le log. Cite le code ORA- observé.
3. Si le résultat diffère de l'énoncé (version, message, vue vide...), dis-le dans le rapport avec `\ecart{...}`.
   Ne cache jamais un écart. Si une fonctionnalité n'existe pas dans 26ai Free : montre l'erreur réelle et explique.
4. L'état persiste d'un chapitre à l'autre (utilisateurs, rôles, profils). Ne supprime rien en dehors de ce que
   l'énoncé demande. Si un objet existe déjà, vérifie l'état au lieu de tout recréer.
5. Garde les mots de passe de l'énoncé. Si tu en changes un (exercices 1.3, 4.x), note le nouveau dans
   `PROGRESS.md` immédiatement.
6. Commandes destructrices hors du périmètre du TP (docker rm, suppression de volume, DROP sur des objets
   Oracle système) : interdites sans demander à l'étudiant.
7. Sessions parallèles et attentes : utilise `&`, `wait`, `EXEC DBMS_SESSION.SLEEP(n)` ou `HOST sleep n`
   (voir PLAYBOOK « motifs »). Jamais de commande qui attend une saisie clavier.
8. Avant de lire la trace d'audit : `EXEC DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL;` (en SYS), sinon les
   événements récents peuvent manquer.

# MODÈLE D'UNE SECTION DU RAPPORT (report/chN.tex)

Chaque `report/chN.tex` commence par `\section{Titre du chapitre}` (ch0 = Préparation, ch1 = Utilisateurs,
ch2 = Privilèges, ch3 = Rôles et modèle RBAC, ch4 = Profils, ch5 = Audit unifié et FGA,
ch6 = Étude de cas : Banque Atlas). Puis, pour chaque exercice :

```latex
\subsection{Exercice 1.1 -- Premier compte}
\textbf{Objectif.} Une phrase.

\shots{1_1}

\textbf{Observations et réponses.}
\begin{enumerate}
  \item Réponse à la question 2 : l'erreur \code{ORA-01045} signifie que ... (cite le log).
  \item ...
\end{enumerate}
\ecart{Seulement s'il y a un écart avec l'énoncé 19c.}
```

Pièges LaTeX : les caractères `_ # % & $ { } ~ ^` doivent être échappés dans le texte normal
(`\_ \# \% \& \$`). Pour les identifiants, codes d'erreur et commandes, utilise `\code{R_RH_LECTEUR}`
(pas besoin d'échapper). Pas d'accolades déséquilibrées. Si `build_report.sh` échoue, lis les lignes
affichées, corrige `report/chN.tex` (jamais `main.tex` sans raison) et relance.

# ÉCARTS ATTENDUS 26ai vs 19c (à vérifier, ne pas supposer)

- Audit : en 26ai l'audit unifié est probablement en mode « pur » (`V$OPTION` Unified Auditing = TRUE).
  Conséquence possible : `DBA_FGA_AUDIT_TRAIL` vide, les enregistrements FGA sont dans `UNIFIED_AUDIT_TRAIL`.
- `DBMS_PRIVILEGE_CAPTURE` (ex. 3.7) peut être indisponible dans l'édition Free : documente l'erreur réelle.
- Profil DEFAULT, fonctions de vérification de mot de passe, contenu des rôles CONNECT/RESOURCE : peuvent
  différer légèrement. Observe, ne suppose pas.
- Le nombre d'utilisateurs maintenus par Oracle (ex. 0.1) n'est pas celui de 19c.

# LIVRABLES FINAUX

`scripts/*.sql` (+ T1..T7 pour l'étude de cas), `logs/*.log`, `screenshots/*.png`,
`compte_rendu_LACHHAB_Mohammed.pdf` (page de garde avec Ensat.jpg déjà faite dans `report/main.tex`).
