-- chu_3_3_c4.sql : DR_FASSI session 3 (garde ouverte 120s)
CONNECT dr_fassi/"Cardio#2026f"@//localhost/FREEPDB1
SELECT USER AS dr_fassi_s3 FROM dual;
EXEC DBMS_SESSION.SLEEP(120);
EXIT
