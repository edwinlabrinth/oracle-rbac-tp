-- chu_3_3_e.sql : Chapitre 3.3 -- Verrouillage mot de passe SEC_LAHLOU (3 echecs puis bon)
CONNECT sec_lahlou/"faux1"@//localhost/FREEPDB1
CONNECT sec_lahlou/"faux2"@//localhost/FREEPDB1
CONNECT sec_lahlou/"faux3"@//localhost/FREEPDB1
CONNECT sec_lahlou/"Accueil#2026l"@//localhost/FREEPDB1

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
COLUMN username FORMAT A14
COLUMN account_status FORMAT A20
COLUMN lock_date FORMAT A20
PROMPt === Etat SEC_LAHLOU apres verrouillage ===
SELECT username, account_status, lock_date FROM dba_users WHERE username = 'SEC_LAHLOU';
EXIT
