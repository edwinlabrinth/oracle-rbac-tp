-- 10-init-banque.sql : schéma BANQUE (étude de cas). À exécuter avec :
--   bash tools/sq.sh 6_init < scripts/10-init-banque.sql
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
SHOW CON_NAME

CREATE USER banque NO AUTHENTICATION DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;

CREATE TABLE banque.clients (
  client_id      NUMBER PRIMARY KEY,
  nom            VARCHAR2(60) NOT NULL,
  cin            VARCHAR2(12) UNIQUE,
  telephone      VARCHAR2(20),
  revenu_mensuel NUMBER(10,2),
  conseiller     VARCHAR2(30));

CREATE TABLE banque.comptes (
  compte_id      NUMBER PRIMARY KEY,
  client_id      NUMBER NOT NULL REFERENCES banque.clients,
  type_compte    VARCHAR2(10) CHECK (type_compte IN ('COURANT','EPARGNE')),
  solde          NUMBER(12,2) DEFAULT 0 NOT NULL,
  date_ouverture DATE DEFAULT SYSDATE);

CREATE TABLE banque.operations (
  op_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  compte_id  NUMBER NOT NULL REFERENCES banque.comptes,
  type_op    VARCHAR2(10) CHECK (type_op IN ('DEPOT','RETRAIT')),
  montant    NUMBER(12,2) NOT NULL,
  date_op    DATE DEFAULT SYSDATE,
  agent      VARCHAR2(30));

INSERT INTO banque.clients VALUES (1, 'Amrani Leila',    'K123456', '0661000001', 18000, 'CONS1');
INSERT INTO banque.clients VALUES (2, 'Bouzid Mehdi',    'K234567', '0661000002',  9500, 'CONS1');
INSERT INTO banque.clients VALUES (3, 'Cherkaoui Sara',  'L345678', '0661000003', 42000, 'CONS1');
INSERT INTO banque.clients VALUES (4, 'Daoudi Anas',     'K456789', '0661000004',  6000, 'CONS1');

INSERT INTO banque.comptes VALUES (1001, 1, 'COURANT',  25000, DATE '2020-01-10');
INSERT INTO banque.comptes VALUES (1002, 1, 'EPARGNE', 150000, DATE '2020-01-10');
INSERT INTO banque.comptes VALUES (1003, 2, 'COURANT',   4200, DATE '2021-06-01');
INSERT INTO banque.comptes VALUES (1004, 3, 'COURANT',  98000, DATE '2019-03-15');
INSERT INTO banque.comptes VALUES (1005, 4, 'COURANT',   1500, DATE '2023-09-30');
COMMIT;

-- Vue du guichet : ni revenu, ni conseiller
CREATE VIEW banque.v_clients_guichet AS
  SELECT client_id, nom, cin, telephone FROM banque.clients;

-- Seule porte d'entrée pour les mouvements d'argent (droits du définisseur)
CREATE OR REPLACE PROCEDURE banque.p_operation (
  p_compte NUMBER, p_type VARCHAR2, p_montant NUMBER) AS
  v_solde banque.comptes.solde%TYPE;
BEGIN
  IF p_montant <= 0 OR p_type NOT IN ('DEPOT','RETRAIT') THEN
    RAISE_APPLICATION_ERROR(-20001, 'Opération invalide');
  END IF;
  SELECT solde INTO v_solde FROM banque.comptes WHERE compte_id = p_compte FOR UPDATE;
  IF p_type = 'RETRAIT' AND v_solde < p_montant THEN
    RAISE_APPLICATION_ERROR(-20002, 'Solde insuffisant');
  END IF;
  UPDATE banque.comptes
     SET solde = solde + CASE p_type WHEN 'DEPOT' THEN p_montant ELSE -p_montant END
   WHERE compte_id = p_compte;
  INSERT INTO banque.operations (compte_id, type_op, montant, agent)
  VALUES (p_compte, p_type, p_montant, SYS_CONTEXT('USERENV','SESSION_USER'));
  COMMIT;
END;
/
SHOW ERRORS PROCEDURE banque.p_operation
