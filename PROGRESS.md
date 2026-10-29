# PROGRESS (à tenir à jour après CHAQUE exercice)

## Mots de passe actuels (modifie la ligne dès qu'un mot de passe change)
| Compte | Mot de passe actuel | Remarque |
|---|---|---|
| SYS (PDB FREEPDB1) | Admin#2026 | |
| ALI | Ali#2027 | changé à l'ex. 1.3 ; supprimé à l'ex. 1.6 |
| DEV1 | Dev1#2026 | créé à l'ex. 1.4 |
| LECTEUR1 | Lect1#2026 | |
| OMAR | Omar#2026 | |
| LINA | Lina#2026 | change aux ex. 4.x : noter ici |
| SARA | Sara#2026 | rôle R_RH_PAIE : mot de passe de rôle Paie#2026 |
| A1, A2 | (à choisir, noter ici) | |
| C##SUPERVISEUR | Super#2026 | racine |

## Exercices (cocher [x] quand : script, log, image, section LaTeX faits)
- [x] 0 : 0_init, 0_1
- [x] 1.1  [x] 1.2  [x] 1.3  [x] 1.4  [x] 1.5  [x] 1.6
- [ ] 2.1  [ ] 2.2  [ ] 2.3  [ ] 2.4  [ ] 2.5  [ ] 2.6
- [ ] 3.1  [ ] 3.2  [ ] 3.3  [ ] 3.4  [ ] 3.5  [ ] 3.6  [ ] 3.7
- [ ] 4.1  [ ] 4.2  [ ] 4.3  [ ] 4.4  [ ] 4.5
- [ ] 5.1  [ ] 5.2  [ ] 5.3  [ ] 5.4  [ ] 5.5  [ ] 5.6  [ ] 5.7
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
