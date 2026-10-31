-- chu_3_3_c3.sql : DR_FASSI session 2 (garde ouverte 120s)
CONNECT dr_fassi/"Cardio#2026f"@//localhost/FREEPDB1
SELECT USER AS dr_fassi_s2 FROM dual;
EXEC DBMS_SESSION.SLEEP(120);
EXIT
