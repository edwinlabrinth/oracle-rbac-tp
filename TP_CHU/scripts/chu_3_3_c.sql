-- chu_3_3_c.sql : Chapitre 3.3 -- DR_FASSI 4 sessions (3 max, 4eme echoue)
-- Sessions 1,2,3 de DR_FASSI (P_SOIGNANT : 3 sessions)
CONNECT dr_fassi/"Cardio#2026f"@//localhost/FREEPDB1
SELECT USER AS dr_fassi_s1 FROM dual;
EXIT
