# PROGRESS (à tenir à jour après CHAQUE exercice)

## Mots de passe actuels (modifie la ligne dès qu'un mot de passe change)
| Compte | Mot de passe actuel | Remarque |
|---|---|---|
| SYS (PDB FREEPDB1) | Admin#2026 | |
| ALI | Ali#2027 | changé à l'ex. 1.3 ; supprimé à l'ex. 1.6 |
| DEV1 | Dev1#2026 | créé à l'ex. 1.4 |
| LECTEUR1 | Lect1#2026 | |
| OMAR | Omar#2026 | |
| LINA | Lina#2032 | mot de passe inchangé après 4.4 (tentatives faibles rejetées ORA-28003/28221) |
| SARA | Sara#2026 | rôle R_RH_PAIE : mot de passe de rôle Paie#2026 |
| A1, A2 | (à choisir, noter ici) | |
| C##SUPERVISEUR | Super#2026 | racine |

## Exercices (cocher [x] quand : script, log, image, section LaTeX faits)
- [x] 0 : 0_init, 0_1
- [x] 1.1  [x] 1.2  [x] 1.3  [x] 1.4  [x] 1.5  [x] 1.6
- [x] 2.1  [x] 2.2  [x] 2.3  [x] 2.4  [x] 2.5  [x] 2.6
- [x] 3.1  [x] 3.2  [x] 3.3  [x] 3.4  [x] 3.5  [x] 3.6  [x] 3.7
- [x] 4.1  [x] 4.2  [x] 4.3  [x] 4.4  [x] 4.5
- [x] 5.1  [x] 5.2  [x] 5.3  [x] 5.4  [x] 5.5  [x] 5.6  [x] 5.7
- [ ] 6.1 (T1)  [ ] 6.2 (T2)  [ ] 6.3 (T3)  [ ] 6.4 (T4)  [ ] 6.5 (T5)  [ ] 6.6 (T6)  [ ] 6.7 (T7)  [ ] 6.8
- [ ] Rapport final compilé (PDF OK)

## État de la base (objets créés / supprimés, écarts constatés)
- Chapitre 0 fait. `tools/sq.sh` : `-s` retiré pour que les commandes soient echoées (log `0_test`).
- Utilisateur `RH` créé (`NO AUTHENTICATION`, `AUTHENTICATION_TYPE=NONE`, `ACCOUNT_STATUS=OPEN`,
  `ORACLE_MAINTAINED=N`). Tables `rh.departements` (4 lignes) et `rh.employes` (8 lignes), vue `rh.v_annuaire`.
- `DBA_USERS` : 28 comptes `ORACLE_MAINTAINED='Y'`, 2 comptes `'N'` (= `RH` créé par nous + `PDBADMIN` de l'image).
- Écart 26ai : total des comptes maintenus par Oracle (28) différent de l'énoncé 19c.
- Chapitre 1 fait. `DEV1` créé (`Dev1#2026`, CREATE SESSION, proxy CONNECT THROUGH RH). `RH` a reçu
  `CREATE SESSION` (nécessaire au proxy). `ALI` supprimé (`DROP USER ali CASCADE`) : sa table `NOTES` et
  son quota ont disparu. `C##SUPERVISEUR` créé (`Super#2026`, `CONTAINER=ALL`).
- Écart 26ai : `CREATE USER bob` dans CDB$ROOT **a réussi** (pas d'ORA-65096) car `COMMON_USER_PREFIX`
  est vide ; `BOB` est devenu un utilisateur commun (`COMMON=YES`). `ORA-65094` bien obtenu sur `c##test`.
  `BOB` laissé en place (créé par l'exercice).
- Chapitre 2 fait. DEV1 : CREATE TABLE/VIEW/SEQUENCE/PROCEDURE + quota 20M, objets `PROJETS`, `SEQ_PROJETS`,
  `V_PROJETS`. `LECTEUR1` : READ sur `rh.employes`. `OMAR` : droits uniquement via `rh.v_annuaire`
  (SELECT + UPDATE colonnes poste/dept_id). `A1`, `A2` créés (`A1#2026`, `A2#2026`). `SELECT ANY TABLE` retiré à A2.
- Écart 26ai : manque de droit DML => `ORA-41900` au lieu de `ORA-01031`. `REVOKE` par colonne refusé
  (`ORA-01750`) : révocation faite au niveau table.
- Chapitre 3 fait. Rôles `R_CONNEXION`, `R_RH_LECTEUR`, `R_RH_GESTION`, `R_RH_PAIE` créés et affectés
  (`LINA` $\to$ `R_RH_LECTEUR`, `OMAR` $\to$ `R_RH_GESTION`, `SARA` $\to$ `R_RH_PAIE`). `OMAR` n'a plus de
  droit direct sur les tables. `r_rh_paie` protégé par mot de passe (`Paie#2026`); `SARA` a `R_CONNEXION`
  en direct et `DEFAULT ROLE r_connexion`. Un rôle protégé par mot de passe n'est pas activé à la connexion
  (Sara a reçu `ORA-01045` sans `R_CONNEXION` en direct) : écart avec le comportement 19c attendu.
- Écart 26ai : `CONNECT` contient aussi `SET CONTAINER` ; `RESOURCE` inclut 15 privilèges de création mais
  pas de quota. `ORA-41904` (création de vue) remplace `ORA-00942`. `AUTHID CURRENT_USER` n'a pas suffi à
  la compilation en 26ai. `DBMS_PRIVILEGE_CAPTURE` disponible mais les vues `DBA_USED_OBJPRIVS` /
  `DBA_UNUSED_OBJPRIVS` sont vides sur une capture par contexte `G_CONTEXT`.
- Chapitre 4 fait. `P_RH_TEST` (SESSIONS_PER_USER 2, IDLE_TIME 1) créé et attribué à LINA (4.1).
  Verrouillage après 3 échecs (4.2) : ORA-01017 puis ORA-28000, déverrouillage auto après 2 min.
  Expiration/gracetime (4.3) : ORA-28098 puis EXPIRED(GRACE) au bout de 1 min, ORA-28001/EXPIRED au bout
  de 2 min ; réutilisation immédiate de l'ancien mdp a réussi (écart ORA-28007 attendu). Complexité (4.4) :
  ORA12C_VERIFY_FUNCTION associée ; sans REPLACE -> ORA-28221 ; mdp contenant le login -> ORA-28003.
  LINA garde `Lina#2032`. `P_RH_STANDARD` créé (4.5) avec limites production + ORA12C_VERIFY_FUNCTION.
  `DROP PROFILE p_rh_test CASCADE` : LINA/OMAR/SARA retombent sur DEFAULT puis passent sur P_RH_STANDARD.
- Chapitre 5 fait. Audit unifié : Unified Auditing = TRUE, 16 politiques prédéfinies, aucune activée par défaut.
  Politiques de test créées puis supprimées (pol_rh_salaires, pol_dba, pol_rh_adhoc) ; ORA_LOGON_FAILURES et
  ORA_ACCOUNT_MGMT restées activées. Utilisateurs : STAGIAIRE créé/supprimé (5.3), test_dba créé/supprimé (5.5),
  AUDITEUR créé (Auditeur#2026, CREATE SESSION + AUDIT_VIEWER) (5.7). Séparation des tâches vérifiée (AUDITEUR bloqué
  ORA-01031). Purge de la trace unifiée (CLEAN_AUDIT_TRAIL) effectuée en fin de 5.7. Écart récurrent 26ai :
  DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL -> PLS-00302 ; AUDIT_UNIFIED_ENABLED_POLICIES n'affiche pas les politiques
  activées ; DBA_FGA_AUDIT_TRAIL -> ORA-00904 (FGA dans UNIFIED_AUDIT_TRAIL) ; clause WHEN sur SYS_CONTEXT + littéral
  -> ORA-01756.
