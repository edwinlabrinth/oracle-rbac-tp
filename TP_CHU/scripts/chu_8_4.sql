-- chu_8_4.sql : Chapitre 8.4 -- Trigger de connexion (E8, E10)
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Nettoyage
PROMPT === Nettoyage ===
DROP TRIGGER trg_logon;

-- Trigger AFTER LOGON ON DATABASE
PROMPT === Creation de TRG_LOGON ===
CREATE OR REPLACE TRIGGER trg_logon
  AFTER LOGON ON DATABASE
DECLARE
  v_count NUMBER;
BEGIN
  -- Journaliser LOGON pour les comptes du personnel et APP_CHU
  SELECT COUNT(*) INTO v_count FROM chu.personnel WHERE login = SYS_CONTEXT('USERENV','SESSION_USER');
  
  IF v_count > 0 OR SYS_CONTEXT('USERENV','SESSION_USER') = 'APP_CHU' THEN
    audit_chu.log_evt('LOGON', 'DATABASE',
      'Connexion de ' || SYS_CONTEXT('USERENV','SESSION_USER'));
    
    -- Refuser APP_CHU depuis sqlplus ou SQL Developer
    IF SYS_CONTEXT('USERENV','SESSION_USER') = 'APP_CHU' THEN
      IF SYS_CONTEXT('USERENV','CLIENT_PROGRAM_NAME') LIKE '%sqlplus%'
         OR SYS_CONTEXT('USERENV','CLIENT_PROGRAM_NAME') LIKE '%sqldeveloper%' THEN
        audit_chu.log_evt('REFUS_LOGON', 'APP_CHU',
          'Refus connexion APP_CHU depuis ' || SYS_CONTEXT('USERENV','CLIENT_PROGRAM_NAME'));
        RAISE_APPLICATION_ERROR(-20020, 'Connexion APP_CHU interdite depuis cet outil');
      END IF;
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/

-- Test : DR_ALAMI se connecte (journalise LOGON)
CONNECT dr_alami/"Urgences#2026a"@//localhost/FREEPDB1
SELECT USER AS dr_alami_connecte FROM dual;
EXIT
