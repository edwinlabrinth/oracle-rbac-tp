-- 4_1_session.sql : Session de fond LINA (conservée ouverte, id 4_1_a et 4_1_b)
CONNECT lina/"Lina#2026"@//localhost/FREEPDB1
SELECT USER AS session_lina FROM dual;
EXEC DBMS_SESSION.SLEEP(130)
