# PLAYBOOK : motifs réutilisables et pièges, chapitre par chapitre

Ce fichier donne des PISTES et des PIÈGES. Les résultats réels viennent toujours de l'exécution : si ce
fichier et le log divergent, le log a raison et on le documente dans le rapport (`\ecart{...}`).

## 0. Motifs techniques

### 0.1 Premier test de l'outillage (à faire une fois, id `0_test`)
```sql
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
SHOW CON_NAME
SELECT USER FROM dual;
SELECT tablespace_name FROM dba_tablespaces;
```
Vérifie dans `logs/0_test.log` que les commandes sont bien echoées (`SQL> ...` ou le texte de la commande
suivi du résultat). Si les commandes ne sont pas echoées, retire `-s` dans `tools/sq.sh`.
`SHOW CON_NAME` doit afficher FREEPDB1. Vérifie que le tablespace `USERS` existe.

### 0.2 Plusieurs sessions en parallèle (rôle [ADMIN] + [USER])
```bash
bash tools/sq.sh 4_1_a <<'SQL' &
CONNECT lina/"Lina#2026"@//localhost/FREEPDB1
EXEC DBMS_SESSION.SLEEP(60)
SQL
sleep 3
bash tools/sq.sh 4_1_b <<'SQL'
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
SELECT username, status FROM v$session WHERE username = 'LINA';
SQL
wait
```
Une session « longue » = `CONNECT` + `EXEC DBMS_SESSION.SLEEP(n)` ou `HOST sleep n` (HOST exécute une commande
shell dans le conteneur ; la session reste ouverte et INACTIVE côté base). Pour qu'un événement admin tombe
« entre » deux requêtes d'une session utilisateur, calcule la chronologie (t=0 connexion, t=15 requête, ...) et
place des sleep.

### 0.3 Changement de mot de passe à la connexion (mot de passe expiré : ORA-28001)
SQL*Plus demande alors le nouveau mot de passe deux fois. Entrée tuyautée (pas de `-it`) :
```bash
printf 'Ali#2027\nAli#2027\n' | docker exec -i -e NLS_LANG=AMERICAN_AMERICA.AL32UTF8 oracle \
  sqlplus 'ali/"Ali#2026"@//localhost/FREEPDB1' 2>&1 | tee logs/1_3_expire.log
```
Si le tuyau ne marche pas (le prompt ne lit pas stdin) : `pip3 install pexpect` puis un petit script Python
qui lance `sqlplus`, attend `New password:`, envoie le mot de passe. Le résultat doit contenir la proposition
« Changing password for ... » ; c'est ce que demande l'énoncé.

### 0.4 Lire l'audit
Toujours en SYS, après `EXEC DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL;`. Restreins par heure
(`WHERE event_timestamp > SYSTIMESTAMP - INTERVAL '10' MINUTE`) pour que la sortie tienne dans l'image.
Utilise `COLUMN dbusername FORMAT A12`, `COLUMN sql_text FORMAT A40`, etc.

### 0.5 Reprendre après erreur
Si un objet existe déjà (ORA-01920, ORA-00955...), regarde son état avant de le recréer
(`SELECT ... FROM dba_users WHERE username = '...'`). Ne supprime pas à l'aveugle.

---

## Chapitre 0 : Préparation (ids `0_init`, `0_1`)
- Exécuter `bash tools/sq.sh 0_init < scripts/00-init-rh.sql` (script déjà écrit, fidèle à l'énoncé).
- Exercice 0.1 : comptes de lignes (departements = 4, employes = 8) ; `DBA_USERS` pour RH
  (AUTHENTICATION_TYPE attendu : NONE) ; compter `ORACLE_MAINTAINED='Y'` et `'N'`.

## Chapitre 1 : Utilisateurs (ids `1_1` à `1_6`)
Codes attendus : ORA-01045, ORA-01950, ORA-01536, ORA-28001, ORA-28000, ORA-65096, ORA-65094, ORA-01922.
- 1.1 : ALI sans autre clause ; `CONNECT ali` -> ORA-01045 ; corriger avec `GRANT CREATE SESSION` (privilège
  minimal) ; requêter `DBA_USERS` (colonnes demandées, `WHERE username='ALI'` en MAJUSCULES).
- 1.2 : `GRANT CREATE TABLE` ; en ALI créer `notes` (réussit : segment différé), INSERT -> ORA-01950 ;
  quota 1M ; le bloc PL/SQL s'arrête sur ORA-01536 ; `DBA_TS_QUOTAS` (BYTES, MAX_BYTES) ; -1 = illimité.
- 1.3 : `ALTER USER ali PASSWORD EXPIRE` ; connexion -> motif 0.3 ; verrouillage `ACCOUNT LOCK` -> ORA-28000 ;
  afficher ACCOUNT_STATUS, LOCK_DATE, EXPIRY_DATE après chaque étape ; déverrouiller. Pourquoi verrouiller
  plutôt que supprimer : on garde les objets, la trace d'audit et l'historique, et c'est réversible.
  Mot de passe d'ALI à noter dans PROGRESS.md (Ali#2027).
- 1.4 : `CONNECT rh/"nimportequoi"@...` -> ORA-01017 (compte NO AUTHENTICATION). Créer DEV1 (CREATE SESSION),
  `ALTER USER rh GRANT CONNECT THROUGH dev1;` puis `CONNECT dev1[rh]/"Dev1#2026"@//localhost/FREEPDB1`
  échoue : lire le code et le nom du compte cité (c'est RH qui manque de CREATE SESSION). Le lui accorder,
  réessayer, puis afficher USER, `SYS_CONTEXT('USERENV','PROXY_USER')` et `SELECT table_name FROM user_tables`.
  Intérêt : RH n'a pas de mot de passe à voler ; chaque développeur s'authentifie avec son propre compte ;
  on retire l'accès d'un seul développeur ; l'audit sait qui est derrière (PROXY_USER).
- 1.5 : dans le MÊME script : `CONNECT / AS SYSDBA` (racine, vérifier `SHOW CON_NAME` = CDB$ROOT) ; CREATE USER bob
  -> ORA-65096 ; `CREATE USER c##superviseur IDENTIFIED BY "Super#2026" CONTAINER=ALL;`
  `GRANT CREATE SESSION TO c##superviseur CONTAINER=ALL;` ; reconnexion en SYS dans FREEPDB1 ; CREATE USER c##test
  -> ORA-65094 ; `SELECT username, common FROM dba_users WHERE username IN ('ALI','C##SUPERVISEUR');`
  Faire 1.5 AVANT 1.6 (ALI doit exister).
- 1.6 : DROP USER ali -> ORA-01922 ; pour montrer l'erreur « session ouverte » : ouvrir une session ALI longue
  (motif 0.2) puis `DROP USER ali CASCADE` -> ORA-01940 ; tuer la session :
  `SELECT sid, serial# FROM v$session WHERE username='ALI';` puis
  `ALTER SYSTEM KILL SESSION 'sid,serial#' IMMEDIATE;` ; puis `DROP USER ali CASCADE`. La table NOTES et le quota
  disparaissent avec l'utilisateur (le montrer : `dba_tables`, `dba_ts_quotas`).

## Chapitre 2 : Privilèges (ids `2_1` à `2_6`)
- 2.1 : DEV1 existe (ch. 1) avec CREATE SESSION. `GRANT CREATE TABLE, CREATE VIEW, CREATE SEQUENCE, CREATE PROCEDURE
  TO dev1;` `ALTER USER dev1 QUOTA 20M ON users;` En DEV1 : `SELECT * FROM session_privs;` puis table
  `projets`, séquence, vue. Pourquoi pas UNLIMITED TABLESPACE : c'est un privilège système qui donne un espace
  illimité dans TOUS les tablespaces (contourne le contrôle de quota).
- 2.2 : LECTEUR1 : SELECT rh.employes OK ; UPDATE -> ORA-01031 (il voit la table mais n'a pas le droit) ;
  SELECT rh.departements -> ORA-00942 (aucun privilège : la table est « invisible »). Puis `GRANT READ ...`,
  `REVOKE SELECT ...` ; SELECT passe ; `SELECT ... FOR UPDATE` échoue (READ n'autorise pas le verrouillage).
- 2.3 : OMAR + `GRANT UPDATE (poste, dept_id) ON rh.employes TO omar;` Trois UPDATE avec ROLLBACK. Afficher
  `SHOW PARAMETER sql92_security` (en SYS). Explication : avec SQL92_SECURITY=TRUE, un UPDATE/DELETE avec
  clause WHERE exige aussi SELECT sur les colonnes lues. Solution par la vue : accorder
  `SELECT, UPDATE (poste, dept_id)` sur `rh.v_annuaire` à OMAR (vue simple, donc modifiable), retirer tous les droits
  de OMAR sur `rh.employes`, tester `UPDATE rh.v_annuaire SET poste=... WHERE emp_id=3` (doit passer) et une
  tentative sur `salaire` via la vue (doit échouer : colonne absente). Vérifier `DBA_COL_PRIVS` et `DBA_TAB_PRIVS`.
- 2.4 : A1, A2 (CREATE SESSION). `GRANT SELECT ON rh.departements TO a1 WITH GRANT OPTION;` ; en A1 : accorder
  à A2 ; `DBA_TAB_PRIVS` (GRANTEE, GRANTOR, GRANTABLE) ; `REVOKE` à A1 ; A2 perd l'accès (cascade) -> ORA-00942.
- 2.5 : `GRANT CREATE VIEW TO a1 WITH ADMIN OPTION;` ; A1 -> A2 ; REVOKE à A1 ; A2 garde CREATE VIEW
  (`DBA_SYS_PRIVS`). Tableau de différences dans le rapport. Plus dangereux pour un auditeur : ADMIN OPTION,
  car la révocation ne se propage pas (privilèges « orphelins » difficiles à retrouver).
- 2.6 : `GRANT SELECT ANY TABLE TO a2;` A2 : rh.employes OK, dev1.projets OK, sys.user$ -> ORA-00942 (le
  dictionnaire est protégé). Lister les comptes non Oracle avec un privilège `LIKE '%ANY%'` direct
  (jointure avec `dba_users WHERE oracle_maintained='N'`), puis `REVOKE SELECT ANY TABLE FROM a2`.

## Chapitre 3 : Rôles et RBAC (ids `3_1` à `3_7`)
- 3.1 : matrice (dans le rapport, tableau LaTeX) :
  R_CONNEXION = CREATE SESSION ; R_RH_LECTEUR = SELECT rh.departements, SELECT rh.v_annuaire ;
  R_RH_GESTION = hérite R_RH_LECTEUR + SELECT, INSERT rh.employes + UPDATE (poste, dept_id) rh.employes ;
  R_RH_PAIE = SELECT rh.employes + UPDATE (salaire) rh.employes. R_CONNEXION accordé aux trois rôles métier.
  Utilisateurs : LINA -> R_RH_LECTEUR, OMAR -> R_RH_GESTION, SARA -> R_RH_PAIE.
  Créer LINA et SARA (`Lina#2026`, `Sara#2026`, quota inutile). Retirer à OMAR TOUT ce qu'il a directement
  (privilèges objet sur la table ET sur la vue du chap. 2, et son CREATE SESSION direct : il passera par le rôle).
  Test par compte : `SELECT * FROM session_roles;` + un accès autorisé + un accès refusé.
- 3.2 : `DBA_ROLE_PRIVS WHERE grantee='OMAR'` ne montre que R_RH_GESTION : R_RH_LECTEUR est accordé au rôle,
  pas à OMAR. Arbre :
  `SELECT LPAD(' ',2*(LEVEL-1))||granted_role r FROM dba_role_privs START WITH grantee='OMAR'
   CONNECT BY PRIOR granted_role = grantee;`
  Privilèges objet via rôles : joindre `dba_tab_privs` (+ `dba_col_privs`) sur les rôles de l'arbre (UNION avec
  les droits directs). Essayer aussi `ROLE_TAB_PRIVS`.
- 3.3 : chronologie avec une session LINA de fond (motif 0.2). Étape 1 : count avant GRANT -> ORA-00942, après
  `GRANT SELECT ON rh.employes TO r_rh_lecteur` -> réussit sans reconnexion. Étape 2 : `REVOKE` de ce GRANT, créer
  `r_test` (SELECT rh.employes), l'accorder à LINA : même session -> échec ; après `SET ROLE ALL;` -> réussite ;
  nouvelle connexion -> réussite. À la fin : `DROP ROLE r_test` et vérifier que R_RH_LECTEUR n'a plus de droit sur
  rh.employes (Lina ne doit PAS voir les salaires). Conclusion : un REVOKE de rôle n'affecte pas les sessions déjà
  ouvertes (le rôle reste actif jusqu'à la fin de la session) donc il faut aussi tuer les sessions.
- 3.4 : `ALTER ROLE r_rh_paie IDENTIFIED BY "Paie#2026";` Sara se reconnecte : le rôle est déjà dans SESSION_ROLES
  sans mot de passe (rôle par défaut). PIÈGE : SARA n'a CREATE SESSION que via R_RH_PAIE -> `GRANT r_connexion TO
  sara;` directement, puis `ALTER USER sara DEFAULT ROLE ALL EXCEPT r_rh_paie;` (ou `DEFAULT ROLE r_connexion`).
  `DBA_ROLE_PRIVS` colonne DEFAULT_ROLE. En SARA : `SET ROLE r_rh_paie IDENTIFIED BY "mauvais";` -> ORA-01979 ;
  avec le bon -> OK. (Pour les chapitres 5 et 6 : Sara doit activer le rôle avec `SET ROLE` + mot de passe.)
- 3.5 : `GRANT CREATE PROCEDURE, CREATE VIEW TO r_rh_gestion;` quota 5M pour OMAR ; la fonction `nb_employes` se
  compile avec erreur (`SHOW ERRORS` -> ORA-00942 / PLS-) ; `CREATE VIEW v_effectif` -> ORA-00942. Raison : le code
  PL/SQL nommé (droits du définisseur) et les vues n'utilisent que les privilèges accordés DIRECTEMENT au propriétaire,
  pas ceux reçus via un rôle. Correction la plus restreinte : `GRANT SELECT ON rh.employes TO omar;` (direct, un
  seul objet, pas de ANY), recompiler, créer la vue. Option à tester et rapporter : `AUTHID CURRENT_USER`.
  Noter que ce grant direct est une exception au principe RBAC.
- 3.6 : `SELECT * FROM role_sys_privs WHERE role IN ('CONNECT','RESOURCE') ORDER BY 1,2;` TEST_RES : créer, `GRANT
  CONNECT, RESOURCE`, table OK, INSERT -> ORA-01950 (pas de quota : RESOURCE n'inclut plus UNLIMITED TABLESPACE).
  Pourquoi pas de base RBAC : rôles historiques larges et figés, contenu qui change selon la version, pas alignés sur
  les fonctions métier, donnent des droits inutiles (types, triggers...).
- 3.7 (facultatif) : `DBMS_PRIVILEGE_CAPTURE.CREATE_CAPTURE(name=>'cap_omar', type=>DBMS_PRIVILEGE_CAPTURE.G_CONTEXT,
  condition=>'SYS_CONTEXT(''USERENV'',''SESSION_USER'')=''OMAR''')`, `ENABLE_CAPTURE`, activité d'OMAR (annuaire,
  UPDATE poste, ROLLBACK), `DISABLE_CAPTURE`, `GENERATE_RESULT`, puis `DBA_USED_OBJPRIVS` vs `DBA_UNUSED_OBJPRIVS`
  filtrées sur `capture='CAP_OMAR'`, puis `DROP_CAPTURE`. Si une erreur indique que la fonctionnalité est
  indisponible : montre le log, explique, passe à la suite.

## Chapitre 4 : Profils (ids `4_1` à `4_5`)
Codes : ORA-02391, ORA-02396, ORA-28000, ORA-28002, ORA-28001, ORA-28007, ORA-28003, ORA-28221.
- Garde le suivi des mots de passe de LINA dans PROGRESS.md : chaque changement de mot de passe doit être différent
  des précédents (règle de réutilisation).
- 4.1 : `SHOW PARAMETER resource_limit` ; P_RH_TEST (SESSIONS_PER_USER 2, IDLE_TIME 1) -> LINA. Trois sessions : deux
  sessions de fond (motif 0.2, sleep 150), la troisième -> ORA-02391. Inactivité : session LINA `CONNECT`, `HOST sleep 150`,
  puis `SELECT 1 FROM dual;` -> ORA-02396 ; pendant l'attente (vers t=100 s), session SYS :
  `SELECT username,status FROM v$session WHERE username='LINA';` (INACTIVE puis SNIPED). `DBA_PROFILES` du profil ;
  DEFAULT dans LIMIT = reprend la valeur du profil DEFAULT.
- 4.2 : `ALTER PROFILE p_rh_test LIMIT FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 2/1440;` trois mauvais mots de passe
  (`CONNECT lina/"faux"@...` -> ORA-01017) puis le bon -> ORA-28000 ; `ACCOUNT_STATUS` = LOCKED(TIMED) + LOCK_DATE ;
  `HOST sleep 130` puis reconnexion OK (déverrouillage automatique). Risques : UNLIMITED = force brute possible ; trop
  bas pour un compte applicatif = n'importe qui peut le verrouiller (déni de service).
- 4.3 : `PASSWORD_REUSE_TIME 30 PASSWORD_REUSE_MAX 3` ; LINA change son mot de passe (`ALTER USER lina IDENTIFIED BY
  "Lina#2027" REPLACE "Lina#2026";`) puis tente de reprendre l'ancien -> ORA-28007. Puis LIFE_TIME et GRACE_TIME à
  1/1440 ; l'admin change le mot de passe de LINA (un mot de passe jamais utilisé) ; connexion après ~65 s ->
  ORA-28002 (EXPIRED(GRACE)) ; encore ~65 s plus tard -> ORA-28001 (EXPIRED). Montrer `ACCOUNT_STATUS` entre chaque.
  Rétablir 90 / 7 ; si LINA est restée EXPIRED, l'admin lui redonne un mot de passe neuf (le noter).
- 4.4 : `SELECT object_name, status FROM dba_objects WHERE owner='SYS' AND object_name LIKE 'ORA12C%';`
  Si absente : sauvegarder `SELECT resource_name, limit FROM dba_profiles WHERE profile='DEFAULT'` dans un log
  (`4_4_default_avant`), lancer `@?/rdbms/admin/utlpwdmg.sql` dans la PDB (depuis le script SQL*Plus, en SYS),
  puis RESTAURER chaque limite du profil DEFAULT à ses valeurs d'origine (`ALTER PROFILE default LIMIT ...`, y compris
  `PASSWORD_VERIFY_FUNCTION NULL` si c'était NULL) et le prouver par un second SELECT. Associer la fonction à P_RH_TEST ;
  tester `lina`, `abcdefgh`, `Lina2026x` avec `ALTER USER lina IDENTIFIED BY ...` (ORA-28003 attendu pour les
  mots de passe trop faibles ; observe lequel passe réellement et explique d'après le message). En LINA : sans
  REPLACE -> ORA-28221, avec REPLACE -> OK.
- 4.5 : créer P_RH_STANDARD (bloc de l'atelier 4.1 de l'énoncé). `DROP PROFILE p_rh_test CASCADE;` AVANT d'affecter
  P_RH_STANDARD : montrer que LINA retombe sur le profil DEFAULT, puis affecter P_RH_STANDARD à LINA, OMAR, SARA.
  `SELECT username, profile, account_status, expiry_date FROM dba_users WHERE oracle_maintained='N';`
  P_SERVICE (batch) : mot de passe sans expiration (PASSWORD_LIFE_TIME UNLIMITED), pas d'IDLE_TIME/CONNECT_TIME
  restrictifs, plusieurs sessions autorisées ; en contrepartie durcir : mot de passe long et complexe (fonction forte),
  FAILED_LOGIN_ATTEMPTS raisonnable avec verrouillage court (éviter le déni de service), réutilisation interdite,
  comptes sans privilège superflu.

## Chapitre 5 : Audit (ids `5_1` à `5_7`)
Rappels : FLUSH avant de lire (motif 0.4). Ne jamais purger avant la toute fin du 5.7.
- 5.1 : `SELECT parameter, value FROM v$option WHERE parameter='Unified Auditing';` interpréter (TRUE = mode pur).
  `AUDIT_UNIFIED_ENABLED_POLICIES` (ENTITY_NAME, SUCCESS, FAILURE) ; `SELECT COUNT(DISTINCT policy_name) FROM
  audit_unified_policies;`
- 5.2 : `CONNECT omar/"faux"@...` x2 et `CONNECT pirate/"x"@...` ; trace : `UNIFIED_AUDIT_TRAIL` avec `action_name='LOGON'
  AND return_code<>0` (event_timestamp, dbusername, userhost, client_program_name, return_code,
  unified_audit_policies). Mauvais mot de passe : 1017. Politique : ORA_LOGON_FAILURES.
- 5.3 : `AUDIT POLICY ora_account_mgmt;` puis STAGIAIRE : create, `GRANT r_rh_lecteur`, `REVOKE`, `DROP USER`. Lire
  action_name, sql_text, dbusername. Regarder si le mot de passe apparaît dans SQL_TEXT et le dire tel quel.
- 5.4 : `CREATE AUDIT POLICY pol_rh_salaires ACTIONS SELECT, UPDATE, DELETE ON rh.employes;` `AUDIT POLICY ...;`
  SARA (SET ROLE r_rh_paie IDENTIFIED BY "Paie#2026") : SELECT puis `UPDATE rh.employes SET salaire = salaire*1.02
  WHERE emp_id = 7;` + COMMIT ; LINA lit `rh.v_annuaire` ; OMAR lit `rh.employes`. Lire : qui, quoi, quel OBJECT_NAME
  pour l'accès via la vue (observe). Puis `NOAUDIT POLICY` et `AUDIT POLICY ... WHENEVER NOT SUCCESSFUL;`,
  vérifier dans `AUDIT_UNIFIED_ENABLED_POLICIES` (SUCCESS/FAILURE).
- 5.5 : POL_RH_ADHOC : la clause WHEN n'accepte que des comparaisons simples sur SYS_CONTEXT (pas de LIKE) :
  d'abord `SELECT SYS_CONTEXT('USERENV','CLIENT_PROGRAM_NAME') FROM dual;` pour voir la valeur exacte, puis
  `WHEN 'SYS_CONTEXT(''USERENV'',''CLIENT_PROGRAM_NAME'') = ''...valeur...''' EVALUATE PER SESSION`. POL_DBA :
  `CREATE AUDIT POLICY pol_dba ROLES dba;` activer ; `GRANT dba TO a1;` A1 (reconnecté) crée un utilisateur ;
  `REVOKE dba FROM a1;` retrouver l'action. Pourquoi auditer un rôle : couvre automatiquement tous ses privilèges
  présents et futurs, une seule définition à maintenir. Supprimer l'utilisateur temporaire créé.
- 5.6 : FGA :
  `BEGIN DBMS_FGA.ADD_POLICY(object_schema=>'RH', object_name=>'EMPLOYES', policy_name=>'FGA_GROS_SALAIRES',
   audit_condition=>'SALAIRE > 30000', audit_column=>'SALAIRE', statement_types=>'SELECT,UPDATE', enable=>TRUE);
   END;` suivi de `/`. Trois requêtes de SARA ((a) noms seuls, (b) salaires dept 40, (c) salaires dept 10) :
  seule (c) renvoie une ligne à plus de 30000 (Alaoui, 45000). Chercher les enregistrements dans
  `UNIFIED_AUDIT_TRAIL` (colonne `fga_policy_name`) ET `DBA_FGA_AUDIT_TRAIL` et dire lequel contient quoi.
  `DBA_AUDIT_POLICIES`, puis `DBMS_FGA.DISABLE_POLICY('RH','EMPLOYES','FGA_GROS_SALAIRES')`.
- 5.7 : AUDITEUR (CREATE SESSION + AUDIT_VIEWER) lit la trace ; `NOAUDIT POLICY ora_logon_failures;` -> ORA-01031
  attendu (AUDIT_ADMIN requis). Rapport : COUNT(*) GROUP BY dbusername, action_name, 24 h. Supprimer POL_RH_ADHOC et
  POL_DBA : tenter `DROP AUDIT POLICY` sur une politique encore active (noter l'erreur), `NOAUDIT POLICY`, puis DROP.
  Purge en toute dernière étape :
  `EXEC DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL(audit_trail_type=>DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
   use_last_arch_timestamp=>FALSE);` puis relire la trace : décrire ce qui reste (la purge elle-même est tracée).

## Chapitre 6 : Étude de cas Banque Atlas (ids `6_...`, scripts `T1.sql` à `T7.sql`)
Exécuter d'abord `bash tools/sq.sh 6_init < scripts/10-init-banque.sql` (fidèle à l'énoncé). Les livrables
demandés sont T1.sql à T7.sql (scripts SQL commentés) ; T1 est surtout un tableau LaTeX (matrice).
Indications de conception (à justifier dans le rapport, case par case, par E1-E3) :
- Rôles : R_BQ_CONNEXION = CREATE SESSION ; R_BQ_GUICHET = (hérite R_BQ_CONNEXION) SELECT sur banque.v_clients_guichet,
  SELECT sur banque.comptes, EXECUTE sur banque.p_operation ; R_BQ_CONSEILLER = hérite R_BQ_GUICHET + SELECT clients
  (fiche complète), SELECT operations, INSERT clients, INSERT comptes, UPDATE (telephone, revenu_mensuel, conseiller) sur
  clients (jamais cin) ; R_BQ_DIRECTEUR = hérite R_BQ_CONSEILLER ; R_BQ_AUDIT = (hérite R_BQ_CONNEXION) SELECT sur les
  3 tables + rôle AUDIT_VIEWER, aucun droit de modification ; R_BQ_BATCH = (hérite R_BQ_CONNEXION) EXECUTE p_operation +
  SELECT comptes. Personne n'a UPDATE sur comptes.solde (E3) ; seul le code de BANQUE.P_OPERATION (droits du définisseur)
  modifie les soldes.
- Seul privilège avec retransmission : `GRANT r_bq_guichet TO dir1 WITH ADMIN OPTION;` (directement au compte DIR1, pas
  via le rôle R_BQ_DIRECTEUR). Les tests 10 et 11 le vérifient (ORA-01932 pour R_BQ_CONSEILLER).
- Profils (T2) : P_BQ_AGENT = guichetiers (SESSIONS_PER_USER 1, IDLE_TIME 10, FAILED_LOGIN_ATTEMPTS 3,
  PASSWORD_LOCK_TIME 30/1440, PASSWORD_LIFE_TIME 60, PASSWORD_REUSE_TIME 365 (+ PASSWORD_REUSE_MAX, vérifie le
  comportement), fonction ORA12C_VERIFY_FUNCTION) ; la limite de sessions étant un paramètre de profil, le conseiller
  (2 sessions) nécessite un second profil P_BQ_CONSEIL (copie avec SESSIONS_PER_USER 2 ; le script de nettoyage de
  l'énoncé le prévoit) ; discute dans le rapport l'alternative (un seul profil + trigger de connexion), ses
  avantages/inconvénients. P_BQ_SENSIBLE = mêmes règles E4 que l'agent mais avec ORA12C_STRONG_VERIFY_FUNCTION
  (mots de passe plus longs/complexes : respecte la fonction à la création du compte). P_BQ_SERVICE = batch : pas
  d'expiration de mot de passe (PASSWORD_LIFE_TIME UNLIMITED), durcir autrement (comme au 4.5). Si les fonctions de vérification
  n'existent pas, lance `utlpwdmg.sql` comme au 4.4 (et restaure DEFAULT ensuite).
- Comptes (T3) : GUI1, GUI2 (+ GUI3 sans privilège, profil P_BQ_AGENT) ; CONS1 (P_BQ_CONSEIL) ; DIR1, AUD1
  (P_BQ_SENSIBLE) ; APP_BATCH (P_BQ_SERVICE) ; DEV_BQ. Pas de quota pour eux. DEV_BQ : accès proxy à BANQUE
  (`ALTER USER banque GRANT CONNECT THROUGH dev_bq;`) ; BANQUE a besoin de CREATE SESSION (comme RH au 1.4) et de
  CREATE VIEW ; DEV_BQ n'a pas besoin de quota car les objets qu'il crée appartiennent à BANQUE, qui a le quota.
- Contrôles T4 : (a) arbre des rôles de DIR1 (CONNECT BY, comme au 3.2) ; (b) E1 : aucune ligne dans `DBA_SYS_PRIVS`,
  `DBA_TAB_PRIVS`, `DBA_COL_PRIVS` pour les utilisateurs métier comme grantee ; (c) E2 : aucune ligne pour les rôles
  DBA/CONNECT/RESOURCE atteints directement ou via la hiérarchie, et aucun privilège contenant ANY via les rôles métier.
- Audit (T5) : POL_BQ_CLIENTS = ACTIONS INSERT, UPDATE, DELETE ON banque.clients (succès et échecs) ;
  POL_BQ_SOLDES = ACTIONS UPDATE, INSERT, DELETE ON banque.comptes et ON banque.operations, activée avec
  `WHENEVER NOT SUCCESSFUL` (pourquoi pas les succès : les modifications légitimes passent par P_OPERATION, elles
  noieraient la trace sous du bruit et sont déjà journalisées dans OPERATIONS) ; FGA_BQ_GROS_MONTANTS =
  `DBMS_FGA.ADD_POLICY` sur BANQUE.OPERATIONS, `statement_types=>'INSERT'`, condition `MONTANT >= 50000` ; teste-la
  vraiment (test 5) : si la condition ne se déclenche pas sur INSERT, adapte (retire audit_column, vérifie la syntaxe) et
  documente. Activer `ORA_ACCOUNT_MGMT` (E8). L'identité de l'agent dans la trace : DBUSERNAME / DB_USER = le
  guichetier (SESSION_USER), alors que la procédure s'exécute avec les droits de BANQUE.
- Tests (T6) : un seul script `T6.sql` avec un `CONNECT` par test et une ligne `PROMPT === TEST n ===` avant chacun ;
  logs `6_T6`. Après le test 14 : `ALTER USER gui2 ACCOUNT UNLOCK`. Le tableau final (LaTeX `longtable` ou `tabular`) a
  les colonnes N°, Compte, Action, Attendu, Obtenu, Trace d'audit ; `Obtenu` vient du log, jamais de l'énoncé. Tout
  écart doit être expliqué ET corrigé (corriger la configuration, relancer le test).
- Revue (T7) : requête 1 : `LISTAGG(granted_role, ', ') WITHIN GROUP (ORDER BY granted_role)` de `dba_role_privs`
  jointe à `dba_users` (profil, état, expiry_date), une ligne par utilisateur. Requête 2 : UNION de `dba_tab_privs`
  (owner='BANQUE') pour rôles et utilisateurs. Requête 3 : `UNIFIED_AUDIT_TRAIL` sur 7 jours GROUP BY
  unified_audit_policies, dbusername.
- Questions de synthèse (6.8) : réponds en prose dans le rapport (2 pages), à partir de ce que tu as observé :
  1) départ de GUI2 : verrouiller (`ACCOUNT LOCK`), tuer ses sessions, `REVOKE` des rôles, vérifier qu'il ne possède aucun
     objet, consulter son historique d'audit, puis supprimer plus tard après la durée de conservation ;
  2) P_OPERATION centralise contrôle du solde, mise à jour et journalisation de façon atomique, interdit toute
     modification arbitraire ; un UPDATE(solde) direct permet de contourner tout cela ;
  3) risque de la délégation : le directeur peut créer des habilitations excessives ou frauduleuses ; l'audit
     (ORA_ACCOUNT_MGMT) trace chaque GRANT ; ADMIN OPTION ne se révoque pas en cascade ;
  4) non acceptable dans un contexte strict : citer Oracle Database Vault, Transparent Data Encryption, Data
     Redaction, Virtual Private Database, Oracle Label Security, Audit Vault and Database Firewall (sans les mettre en
     œuvre) ;
  5) limiter le conseiller à ses clients : vue filtrée `WHERE conseiller = SYS_CONTEXT('USERENV','SESSION_USER')`
     (les valeurs de la colonne conseiller sont des noms d'utilisateur) ou politique VPD (DBMS_RLS) ;
  6) deux améliorations argumentées (authentification forte/centralisée, chiffrement TDE + réseau, revue périodique
     des habilitations avec l'analyse des privilèges, double validation des gros retraits, export de la trace vers un SIEM...).

## Fin de TP
1. Dernier `bash tools/build_report.sh` : le PDF doit contenir tous les chapitres et la page de garde.
2. Seulement si l'étudiant le demande : `bash tools/sq.sh 99_nettoyage < scripts/99-nettoyage.sql`.
3. `git add -A && git commit -m "TP termine"` et `git push`.
