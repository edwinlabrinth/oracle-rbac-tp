-- 6_6_fond.sql : Session de fond GUI1 pour le test 7 (2e session simultanee)
CONNECT gui1/"Ag1#Banque2026"@//localhost/FREEPDB1
EXEC DBMS_SESSION.SLEEP(120)
EXIT
