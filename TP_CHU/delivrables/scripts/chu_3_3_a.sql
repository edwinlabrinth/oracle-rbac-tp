-- chu_3_3_a.sql : Chapitre 3.3 -- Test limites de sessions (SEC_LAHLOU : 1 session max)
-- Session 1 de SEC_LAHLOU (garde ouverte)
CONNECT sec_lahlou/"Accueil#2026l"@//localhost/FREEPDB1
SELECT USER AS session_sec_lahlou_1 FROM dual;
EXEC DBMS_SESSION.SLEEP(120);
EXIT
