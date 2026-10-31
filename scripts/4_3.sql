-- 4_3.sql : Exercice 4.3 -- Expiration, gracetime et reutilisation des mots de passe
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Etape 1 : regles de reutilisation (30 jours, max 3 mots de passe memorises)
ALTER PROFILE p_rh_test LIMIT
  PASSWORD_REUSE_TIME 30
  PASSWORD_REUSE_MAX 3;

COLUMN profile FORMAT A14
COLUMN resource_name FORMAT A30
COLUMN limit FORMAT A12
PROMPT === Regles de reutilisation de P_RH_TEST ===
SELECT resource_name, limit
  FROM dba_profiles
 WHERE profile = 'P_RH_TEST'
   AND resource_name IN ('PASSWORD_REUSE_TIME','PASSWORD_REUSE_MAX');

-- Etape 2 : LINA change son mot de passe (Lina#2029 -> Lina#2030), puis tente de reprendre l'ancien
PROMPT === LINA change son mot de passe (Lina#2029 -> Lina#2030) ===
CONNECT lina/"Lina#2029"@//localhost/FREEPDB1
ALTER USER lina IDENTIFIED BY "Lina#2030" REPLACE "Lina#2029";
PROMPT === Tentative de reprendre l'ancien mot de passe Lina#2029 (attendu ORA-28007) ===
ALTER USER lina IDENTIFIED BY "Lina#2029";

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
-- Etape 3 : duree de vie et gracetime courtes (1 minute chacune)
ALTER PROFILE p_rh_test LIMIT
  PASSWORD_LIFE_TIME 1/1440
  PASSWORD_GRACE_TIME 1/1440;
-- L'admin change le mot de passe de Lina (nouveau mot de passe jamais utilise)
ALTER USER lina IDENTIFIED BY "Lina#2031";
COLUMN account_status FORMAT A20
COLUMN expiry_date FORMAT A20
PROMPT === Etat de LINA juste apres le changement par l'admin ===
SELECT username, account_status, expiry_date FROM dba_users WHERE username = 'LINA';

PROMPT === Attente de 65 secondes (> PASSWORD_LIFE_TIME 1 minute) ===
HOST sleep 65
PROMPT === Reconnexion de LINA apres 1 minute (attendu ORA-28002, periode de grace) ===
CONNECT lina/"Lina#2031"@//localhost/FREEPDB1

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
PROMPT === Etat de LINA pendant la periode de grace ===
SELECT username, account_status, expiry_date FROM dba_users WHERE username = 'LINA';

PROMPT === Attente de 65 secondes supplémentaires (total > 2 minutes, grace depassee) ===
HOST sleep 65
PROMPT === Reconnexion de LINA apres 2 minutes (attendu ORA-28001, mot de passe expire) ===
CONNECT lina/"Lina#2031"@//localhost/FREEPDB1

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
PROMPT === Etat final de LINA (mot de passe expire) ===
SELECT username, account_status, expiry_date FROM dba_users WHERE username = 'LINA';

-- Etape 4 : restauration des valeurs normales et mot de passe neuf pour LINA
ALTER PROFILE p_rh_test LIMIT
  PASSWORD_LIFE_TIME 90
  PASSWORD_GRACE_TIME 7;
ALTER USER lina IDENTIFIED BY "Lina#2032";
PROMPT === Etat de LINA apres restauration ===
SELECT username, account_status, expiry_date FROM dba_users WHERE username = 'LINA';
EXIT
