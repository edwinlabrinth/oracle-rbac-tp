-- =====================================================================
-- TP Audit — CHU Al Majd de Tanger (établissement fictif)
-- 01_schema_dataset.sql : schéma CHU + jeu de données (données fictives)
-- À exécuter connecté en SYS dans la PDB (ex. ORCLPDB)
-- =====================================================================
CREATE USER chu NO AUTHENTICATION DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;

CREATE TABLE chu.services (
  service_id NUMBER PRIMARY KEY,
  nom        VARCHAR2(40) NOT NULL,
  batiment   VARCHAR2(10));

CREATE TABLE chu.personnel (
  pers_id       NUMBER PRIMARY KEY,
  nom           VARCHAR2(40) NOT NULL,
  prenom        VARCHAR2(40),
  fonction      VARCHAR2(12) CHECK (fonction IN ('MEDECIN','INFIRMIER','SECRETAIRE','PHARMACIEN','COMPTABLE','DIRECTEUR','DPO')),
  service_id    NUMBER REFERENCES chu.services,
  login         VARCHAR2(30) UNIQUE,
  date_embauche DATE);

CREATE TABLE chu.patients (
  patient_id     NUMBER PRIMARY KEY,
  cin            VARCHAR2(10) UNIQUE,
  nom            VARCHAR2(40) NOT NULL,
  prenom         VARCHAR2(40),
  date_naissance DATE,
  sexe           CHAR(1) CHECK (sexe IN ('F','M')),
  telephone      VARCHAR2(15),
  ville          VARCHAR2(30),
  mutuelle       VARCHAR2(10) CHECK (mutuelle IN ('CNSS','CNOPS','AMO','AUCUNE')),
  vip            CHAR(1) DEFAULT 'N' CHECK (vip IN ('O','N')));

CREATE TABLE chu.sejours (
  sejour_id   NUMBER PRIMARY KEY,
  patient_id  NUMBER NOT NULL REFERENCES chu.patients,
  service_id  NUMBER NOT NULL REFERENCES chu.services,
  medecin_id  NUMBER NOT NULL REFERENCES chu.personnel,
  date_entree DATE NOT NULL,
  date_sortie DATE,
  motif       VARCHAR2(60));

CREATE TABLE chu.dossiers_medicaux (
  dossier_id   NUMBER PRIMARY KEY,
  sejour_id    NUMBER NOT NULL UNIQUE REFERENCES chu.sejours,
  diagnostic   VARCHAR2(80),
  antecedents  VARCHAR2(80),
  traitement   VARCHAR2(80),
  confidentiel CHAR(1) DEFAULT 'N' CHECK (confidentiel IN ('O','N')),
  maj_le       DATE);

CREATE TABLE chu.prescriptions (
  presc_id   NUMBER PRIMARY KEY,
  sejour_id  NUMBER NOT NULL REFERENCES chu.sejours,
  medecin_id NUMBER NOT NULL REFERENCES chu.personnel,
  medicament VARCHAR2(40) NOT NULL,
  dose       VARCHAR2(30),
  date_presc DATE,
  statut     VARCHAR2(10) CHECK (statut IN ('PRESCRITE','DELIVREE','ANNULEE')));

CREATE TABLE chu.factures (
  facture_id    NUMBER PRIMARY KEY,
  sejour_id     NUMBER NOT NULL REFERENCES chu.sejours,
  montant       NUMBER(10,2),
  part_mutuelle NUMBER(10,2),
  statut        VARCHAR2(8) CHECK (statut IN ('EMISE','PAYEE')),
  date_emission DATE);

-- Services
INSERT INTO chu.services VALUES (10, 'Urgences', 'A');
INSERT INTO chu.services VALUES (20, 'Cardiologie', 'B');
INSERT INTO chu.services VALUES (30, 'Pédiatrie', 'C');
INSERT INTO chu.services VALUES (40, 'Oncologie', 'D');
INSERT INTO chu.services VALUES (50, 'Pharmacie', 'E');
INSERT INTO chu.services VALUES (60, 'Administration', 'F');
-- Personnel (le login est le nom du compte Oracle de la personne)
INSERT INTO chu.personnel VALUES (1, 'Alami', 'Youssef', 'MEDECIN', 10, 'DR_ALAMI', DATE '2012-01-01');
INSERT INTO chu.personnel VALUES (2, 'Benali', 'Salma', 'MEDECIN', 20, 'DR_BENALI', DATE '2013-02-04');
INSERT INTO chu.personnel VALUES (3, 'Chraibi', 'Karim', 'MEDECIN', 30, 'DR_CHRAIBI', DATE '2014-03-07');
INSERT INTO chu.personnel VALUES (4, 'Daoudi', 'Nadia', 'MEDECIN', 40, 'DR_DAOUDI', DATE '2015-04-10');
INSERT INTO chu.personnel VALUES (5, 'El Idrissi', 'Omar', 'MEDECIN', 10, 'DR_ELIDRISSI', DATE '2016-05-13');
INSERT INTO chu.personnel VALUES (6, 'Fassi', 'Rim', 'MEDECIN', 20, 'DR_FASSI', DATE '2017-06-16');
INSERT INTO chu.personnel VALUES (7, 'Ghazi', 'Hamza', 'INFIRMIER', 10, 'INF_GHAZI', DATE '2018-07-19');
INSERT INTO chu.personnel VALUES (8, 'Haddad', 'Imane', 'INFIRMIER', 20, 'INF_HADDAD', DATE '2019-08-22');
INSERT INTO chu.personnel VALUES (9, 'Idrissi', 'Anas', 'INFIRMIER', 30, 'INF_IDRISSI', DATE '2020-09-25');
INSERT INTO chu.personnel VALUES (10, 'Jabri', 'Leila', 'INFIRMIER', 40, 'INF_JABRI', DATE '2021-10-01');
INSERT INTO chu.personnel VALUES (11, 'Kettani', 'Sara', 'SECRETAIRE', 10, 'SEC_KETTANI', DATE '2022-11-04');
INSERT INTO chu.personnel VALUES (12, 'Lahlou', 'Mehdi', 'SECRETAIRE', 20, 'SEC_LAHLOU', DATE '2012-12-07');
INSERT INTO chu.personnel VALUES (13, 'Mansouri', 'Hind', 'PHARMACIEN', 50, 'PHA_MANSOURI', DATE '2013-01-10');
INSERT INTO chu.personnel VALUES (14, 'Naciri', 'Adil', 'PHARMACIEN', 50, 'PHA_NACIRI', DATE '2014-02-13');
INSERT INTO chu.personnel VALUES (15, 'Ouazzani', 'Yasmine', 'COMPTABLE', 60, 'CPT_OUAZZANI', DATE '2015-03-16');
INSERT INTO chu.personnel VALUES (16, 'Rami', 'Khalid', 'DIRECTEUR', 60, 'DIR_RAMI', DATE '2016-04-19');
INSERT INTO chu.personnel VALUES (17, 'Sbai', 'Meriem', 'DPO', 60, 'DPO_SBAI', DATE '2017-05-22');
INSERT INTO chu.personnel VALUES (18, 'Tazi', 'Ilyas', 'INFIRMIER', 10, 'INF_TAZI', DATE '2018-06-25');
INSERT INTO chu.personnel VALUES (19, 'Zerouali', 'Kawtar', 'MEDECIN', 30, 'DR_ZEROUALI', DATE '2019-07-01');
INSERT INTO chu.personnel VALUES (20, 'Amrani', 'Fouad', 'SECRETAIRE', 30, 'SEC_AMRANI', DATE '2020-08-04');
-- Patients (données fictives)
INSERT INTO chu.patients VALUES (1, 'K107919', 'Amrani', 'Salma', DATE '1947-06-12', 'F', '0661001234', 'Tétouan', 'CNOPS', 'N');
INSERT INTO chu.patients VALUES (2, 'K115838', 'Bakkali', 'Yassine', DATE '1954-11-23', 'M', '0661002468', 'Larache', 'AMO', 'N');
INSERT INTO chu.patients VALUES (3, 'L123757', 'Belhaj', 'Kenza', DATE '1961-04-06', 'F', '0661003702', 'Asilah', 'AUCUNE', 'N');
INSERT INTO chu.patients VALUES (4, 'K131676', 'Benjelloun', 'Amine', DATE '1968-09-17', 'M', '0661004936', 'Fnideq', 'CNSS', 'N');
INSERT INTO chu.patients VALUES (5, 'K139595', 'Berrada', 'Nour', DATE '1975-02-28', 'F', '0661006170', 'Ksar El Kebir', 'CNOPS', 'N');
INSERT INTO chu.patients VALUES (6, 'L147514', 'Bouzid', 'Hamza', DATE '1982-07-11', 'M', '0661007404', 'Tanger', 'AMO', 'N');
INSERT INTO chu.patients VALUES (7, 'K155433', 'Cherkaoui', 'Malak', DATE '1989-12-22', 'F', '0661008638', 'Tétouan', 'AUCUNE', 'O');
INSERT INTO chu.patients VALUES (8, 'K163352', 'Chafik', 'Saad', DATE '1996-05-05', 'M', '0661009872', 'Larache', 'CNSS', 'N');
INSERT INTO chu.patients VALUES (9, 'L171271', 'Douiri', 'Sanae', DATE '2003-10-16', 'F', '0661011106', 'Asilah', 'CNOPS', 'N');
INSERT INTO chu.patients VALUES (10, 'K179190', 'El Amrani', 'Adam', DATE '2010-03-27', 'M', '0661012340', 'Fnideq', 'AMO', 'N');
INSERT INTO chu.patients VALUES (11, 'K187109', 'El Khatib', 'Salma', DATE '2017-08-10', 'F', '0661013574', 'Ksar El Kebir', 'AUCUNE', 'N');
INSERT INTO chu.patients VALUES (12, 'L195028', 'Ennaji', 'Yassine', DATE '1944-01-21', 'M', '0661014808', 'Tanger', 'CNSS', 'N');
INSERT INTO chu.patients VALUES (13, 'K202947', 'Filali', 'Kenza', DATE '1951-06-04', 'F', '0661016042', 'Tétouan', 'CNOPS', 'N');
INSERT INTO chu.patients VALUES (14, 'K210866', 'Guessous', 'Amine', DATE '1958-11-15', 'M', '0661017276', 'Larache', 'AMO', 'N');
INSERT INTO chu.patients VALUES (15, 'L218785', 'Hajji', 'Nour', DATE '1965-04-26', 'F', '0661018510', 'Asilah', 'AUCUNE', 'N');
INSERT INTO chu.patients VALUES (16, 'K226704', 'Hamdaoui', 'Hamza', DATE '1972-09-09', 'M', '0661019744', 'Fnideq', 'CNSS', 'N');
INSERT INTO chu.patients VALUES (17, 'K234623', 'Jaidi', 'Malak', DATE '1979-02-20', 'F', '0661020978', 'Ksar El Kebir', 'CNOPS', 'N');
INSERT INTO chu.patients VALUES (18, 'L242542', 'Kabbaj', 'Saad', DATE '1986-07-03', 'M', '0661022212', 'Tanger', 'AMO', 'N');
INSERT INTO chu.patients VALUES (19, 'K250461', 'Lamrani', 'Sanae', DATE '1993-12-14', 'F', '0661023446', 'Tétouan', 'AUCUNE', 'N');
INSERT INTO chu.patients VALUES (20, 'K258380', 'Lazrak', 'Adam', DATE '2000-05-25', 'M', '0661024680', 'Larache', 'CNSS', 'N');
INSERT INTO chu.patients VALUES (21, 'L266299', 'Mernissi', 'Salma', DATE '2007-10-08', 'F', '0661025914', 'Asilah', 'CNOPS', 'N');
INSERT INTO chu.patients VALUES (22, 'K274218', 'Moussaoui', 'Yassine', DATE '2014-03-19', 'M', '0661027148', 'Fnideq', 'AMO', 'N');
INSERT INTO chu.patients VALUES (23, 'K282137', 'Naji', 'Kenza', DATE '1941-08-02', 'F', '0661028382', 'Ksar El Kebir', 'AUCUNE', 'O');
INSERT INTO chu.patients VALUES (24, 'L290056', 'Ouali', 'Amine', DATE '1948-01-13', 'M', '0661029616', 'Tanger', 'CNSS', 'N');
INSERT INTO chu.patients VALUES (25, 'K297975', 'Raji', 'Nour', DATE '1955-06-24', 'F', '0661030850', 'Tétouan', 'CNOPS', 'N');
INSERT INTO chu.patients VALUES (26, 'K305894', 'Saadi', 'Hamza', DATE '1962-11-07', 'M', '0661032084', 'Larache', 'AMO', 'N');
INSERT INTO chu.patients VALUES (27, 'L313813', 'Sefrioui', 'Malak', DATE '1969-04-18', 'F', '0661033318', 'Asilah', 'AUCUNE', 'N');
INSERT INTO chu.patients VALUES (28, 'K321732', 'Slaoui', 'Saad', DATE '1976-09-01', 'M', '0661034552', 'Fnideq', 'CNSS', 'N');
INSERT INTO chu.patients VALUES (29, 'K329651', 'Tahiri', 'Sanae', DATE '1983-02-12', 'F', '0661035786', 'Ksar El Kebir', 'CNOPS', 'N');
INSERT INTO chu.patients VALUES (30, 'L337570', 'Talbi', 'Adam', DATE '1990-07-23', 'M', '0661037020', 'Tanger', 'AMO', 'N');
INSERT INTO chu.patients VALUES (31, 'K345489', 'Tounsi', 'Salma', DATE '1997-12-06', 'F', '0661038254', 'Tétouan', 'AUCUNE', 'O');
INSERT INTO chu.patients VALUES (32, 'K353408', 'Wahbi', 'Yassine', DATE '2004-05-17', 'M', '0661039488', 'Larache', 'CNSS', 'N');
INSERT INTO chu.patients VALUES (33, 'L361327', 'Yacoubi', 'Kenza', DATE '2011-10-28', 'F', '0661040722', 'Asilah', 'CNOPS', 'N');
INSERT INTO chu.patients VALUES (34, 'K369246', 'Zahraoui', 'Amine', DATE '2018-03-11', 'M', '0661041956', 'Fnideq', 'AMO', 'N');
INSERT INTO chu.patients VALUES (35, 'K377165', 'Ziani', 'Nour', DATE '1945-08-22', 'F', '0661043190', 'Ksar El Kebir', 'AUCUNE', 'N');
INSERT INTO chu.patients VALUES (36, 'L385084', 'Alaoui', 'Hamza', DATE '1952-01-05', 'M', '0661044424', 'Tanger', 'CNSS', 'N');
INSERT INTO chu.patients VALUES (37, 'K393003', 'Bennani', 'Malak', DATE '1959-06-16', 'F', '0661045658', 'Tétouan', 'CNOPS', 'N');
INSERT INTO chu.patients VALUES (38, 'K400922', 'Kadiri', 'Saad', DATE '1966-11-27', 'M', '0661046892', 'Larache', 'AMO', 'N');
INSERT INTO chu.patients VALUES (39, 'L408841', 'Lahbabi', 'Sanae', DATE '1973-04-10', 'F', '0661048126', 'Asilah', 'AUCUNE', 'N');
INSERT INTO chu.patients VALUES (40, 'K416760', 'Ouahbi', 'Adam', DATE '1980-09-21', 'M', '0661049360', 'Fnideq', 'CNSS', 'N');
-- Séjours, dossiers médicaux, prescriptions, factures
INSERT INTO chu.sejours VALUES (1, 14, 20, 6, DATE '2026-08-04', DATE '2026-08-06', 'Arythmie');
INSERT INTO chu.dossiers_medicaux VALUES (1, 1, 'Fibrillation auriculaire', 'Diabète type 2', 'Anticoagulant', 'N', DATE '2026-08-06');
INSERT INTO chu.prescriptions VALUES (1, 1, 6, 'Apixaban', '2 cp/j', DATE '2026-08-04', 'PRESCRITE');
INSERT INTO chu.prescriptions VALUES (2, 1, 6, 'Ramipril', '5 ml x 2/j', DATE '2026-08-05', 'DELIVREE');
INSERT INTO chu.factures VALUES (1, 1, 1737.00, 1215.90, 'PAYEE', DATE '2026-08-06');
INSERT INTO chu.sejours VALUES (2, 27, 30, 3, DATE '2026-08-07', DATE '2026-08-10', 'Asthme');
INSERT INTO chu.dossiers_medicaux VALUES (2, 2, 'Asthme aigu', 'HTA', 'Salbutamol', 'N', DATE '2026-08-10');
INSERT INTO chu.prescriptions VALUES (3, 2, 3, 'SRO', '5 ml x 2/j', DATE '2026-08-07', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (4, 2, 3, 'Paracétamol sirop', '1 inj/j', DATE '2026-08-08', 'ANNULEE');
INSERT INTO chu.prescriptions VALUES (5, 2, 3, 'Salbutamol', '1 cp x 3/j', DATE '2026-08-09', 'DELIVREE');
INSERT INTO chu.factures VALUES (2, 2, 2674.00, 0.00, 'PAYEE', DATE '2026-08-10');
INSERT INTO chu.sejours VALUES (3, 40, 40, 4, DATE '2026-08-10', DATE '2026-08-14', 'Chimiothérapie');
INSERT INTO chu.dossiers_medicaux VALUES (3, 3, 'Lymphome', 'Asthme', 'Protocole R-CHOP', 'O', DATE '2026-08-14');
INSERT INTO chu.prescriptions VALUES (6, 3, 4, 'Ondansétron', '1 inj/j', DATE '2026-08-10', 'ANNULEE');
INSERT INTO chu.factures VALUES (3, 3, 33611.00, 23527.70, 'EMISE', DATE '2026-08-14');
INSERT INTO chu.sejours VALUES (4, 13, 10, 1, DATE '2026-08-13', DATE '2026-08-18', 'Traumatisme');
INSERT INTO chu.dossiers_medicaux VALUES (4, 4, 'Fracture du radius', 'Tabagisme', 'Plâtre + antalgiques', 'N', DATE '2026-08-18');
INSERT INTO chu.prescriptions VALUES (7, 4, 1, 'Paracétamol', '1 cp x 3/j', DATE '2026-08-13', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (8, 4, 1, 'Héparine', '2 cp/j', DATE '2026-08-14', 'PRESCRITE');
INSERT INTO chu.factures VALUES (4, 4, 4548.00, 3638.40, 'PAYEE', DATE '2026-08-18');
INSERT INTO chu.sejours VALUES (5, 26, 20, 6, DATE '2026-08-16', DATE '2026-08-22', 'Hypertension sévère');
INSERT INTO chu.dossiers_medicaux VALUES (5, 5, 'HTA', 'Aucun', 'IEC', 'N', DATE '2026-08-22');
INSERT INTO chu.prescriptions VALUES (9, 5, 6, 'Apixaban', '2 cp/j', DATE '2026-08-16', 'PRESCRITE');
INSERT INTO chu.prescriptions VALUES (10, 5, 6, 'Ramipril', '5 ml x 2/j', DATE '2026-08-17', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (11, 5, 6, 'Bisoprolol', '1 inj/j', DATE '2026-08-18', 'ANNULEE');
INSERT INTO chu.factures VALUES (5, 5, 5485.00, 3839.50, 'PAYEE', DATE '2026-08-22');
INSERT INTO chu.sejours VALUES (6, 39, 30, 3, DATE '2026-08-19', DATE '2026-08-26', 'Bronchiolite');
INSERT INTO chu.dossiers_medicaux VALUES (6, 6, 'Bronchiolite', 'Diabète type 2', 'Kinésithérapie respiratoire', 'N', DATE '2026-08-26');
INSERT INTO chu.prescriptions VALUES (12, 6, 3, 'Paracétamol sirop', '5 ml x 2/j', DATE '2026-08-19', 'DELIVREE');
INSERT INTO chu.factures VALUES (6, 6, 6422.00, 0.00, 'EMISE', DATE '2026-08-26');
INSERT INTO chu.sejours VALUES (7, 12, 40, 4, DATE '2026-08-22', DATE '2026-08-30', 'Bilan tumoral');
INSERT INTO chu.dossiers_medicaux VALUES (7, 7, 'Cancer du sein', 'HTA', 'Protocole AC-T', 'O', DATE '2026-08-30');
INSERT INTO chu.prescriptions VALUES (13, 7, 4, 'Dexaméthasone', '1 inj/j', DATE '2026-08-22', 'ANNULEE');
INSERT INTO chu.prescriptions VALUES (14, 7, 4, 'Morphine', '1 cp x 3/j', DATE '2026-08-23', 'DELIVREE');
INSERT INTO chu.factures VALUES (7, 7, 37359.00, 26151.30, 'PAYEE', DATE '2026-08-30');
INSERT INTO chu.sejours VALUES (8, 25, 10, 1, DATE '2026-08-25', DATE '2026-08-26', 'Traumatisme');
INSERT INTO chu.dossiers_medicaux VALUES (8, 8, 'Fracture du radius', 'Asthme', 'Plâtre + antalgiques', 'N', DATE '2026-08-26');
INSERT INTO chu.prescriptions VALUES (15, 8, 1, 'Paracétamol', '1 cp x 3/j', DATE '2026-08-25', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (16, 8, 1, 'Héparine', '2 cp/j', DATE '2026-08-26', 'PRESCRITE');
INSERT INTO chu.prescriptions VALUES (17, 8, 1, 'Amoxicilline', '5 ml x 2/j', DATE '2026-08-27', 'DELIVREE');
INSERT INTO chu.factures VALUES (8, 8, 8296.00, 6636.80, 'PAYEE', DATE '2026-08-26');
INSERT INTO chu.sejours VALUES (9, 38, 20, 6, DATE '2026-08-28', NULL, 'Insuffisance cardiaque');
INSERT INTO chu.dossiers_medicaux VALUES (9, 9, 'Insuffisance cardiaque', 'Tabagisme', 'Furosémide', 'N', DATE '2026-08-28');
INSERT INTO chu.prescriptions VALUES (18, 9, 6, 'Apixaban', '2 cp/j', DATE '2026-08-28', 'PRESCRITE');
INSERT INTO chu.factures VALUES (9, 9, 9233.00, 6463.10, 'EMISE', DATE '2026-08-28');
INSERT INTO chu.sejours VALUES (10, 11, 30, 3, DATE '2026-08-31', DATE '2026-09-03', 'Gastro-entérite');
INSERT INTO chu.dossiers_medicaux VALUES (10, 10, 'Déshydratation', 'Aucun', 'Réhydratation', 'N', DATE '2026-09-03');
INSERT INTO chu.prescriptions VALUES (19, 10, 3, 'Salbutamol', '5 ml x 2/j', DATE '2026-08-31', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (20, 10, 3, 'SRO', '1 inj/j', DATE '2026-09-01', 'ANNULEE');
INSERT INTO chu.factures VALUES (10, 10, 10170.00, 0.00, 'PAYEE', DATE '2026-09-03');
INSERT INTO chu.sejours VALUES (11, 24, 40, 4, DATE '2026-09-03', DATE '2026-09-07', 'Radiothérapie');
INSERT INTO chu.dossiers_medicaux VALUES (11, 11, 'Cancer colorectal', 'Diabète type 2', 'Protocole FOLFOX', 'O', DATE '2026-09-07');
INSERT INTO chu.prescriptions VALUES (21, 11, 4, 'Morphine', '1 inj/j', DATE '2026-09-03', 'ANNULEE');
INSERT INTO chu.prescriptions VALUES (22, 11, 4, 'Ondansétron', '1 cp x 3/j', DATE '2026-09-04', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (23, 11, 4, 'Dexaméthasone', '2 cp/j', DATE '2026-09-05', 'PRESCRITE');
INSERT INTO chu.factures VALUES (11, 11, 41107.00, 28774.90, 'PAYEE', DATE '2026-09-07');
INSERT INTO chu.sejours VALUES (12, 37, 10, 1, DATE '2026-09-06', DATE '2026-09-11', 'Traumatisme');
INSERT INTO chu.dossiers_medicaux VALUES (12, 12, 'Fracture du radius', 'HTA', 'Plâtre + antalgiques', 'N', DATE '2026-09-11');
INSERT INTO chu.prescriptions VALUES (24, 12, 1, 'Paracétamol', '1 cp x 3/j', DATE '2026-09-06', 'DELIVREE');
INSERT INTO chu.factures VALUES (12, 12, 12044.00, 9635.20, 'EMISE', DATE '2026-09-11');
INSERT INTO chu.sejours VALUES (13, 10, 20, 6, DATE '2026-09-09', DATE '2026-09-15', 'Arythmie');
INSERT INTO chu.dossiers_medicaux VALUES (13, 13, 'Fibrillation auriculaire', 'Asthme', 'Anticoagulant', 'N', DATE '2026-09-15');
INSERT INTO chu.prescriptions VALUES (25, 13, 6, 'Apixaban', '2 cp/j', DATE '2026-09-09', 'PRESCRITE');
INSERT INTO chu.prescriptions VALUES (26, 13, 6, 'Ramipril', '5 ml x 2/j', DATE '2026-09-10', 'DELIVREE');
INSERT INTO chu.factures VALUES (13, 13, 12981.00, 9086.70, 'PAYEE', DATE '2026-09-15');
INSERT INTO chu.sejours VALUES (14, 23, 30, 3, DATE '2026-09-12', DATE '2026-09-19', 'Asthme');
INSERT INTO chu.dossiers_medicaux VALUES (14, 14, 'Asthme aigu', 'Tabagisme', 'Salbutamol', 'O', DATE '2026-09-19');
INSERT INTO chu.prescriptions VALUES (27, 14, 3, 'SRO', '5 ml x 2/j', DATE '2026-09-12', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (28, 14, 3, 'Paracétamol sirop', '1 inj/j', DATE '2026-09-13', 'ANNULEE');
INSERT INTO chu.prescriptions VALUES (29, 14, 3, 'Salbutamol', '1 cp x 3/j', DATE '2026-09-14', 'DELIVREE');
INSERT INTO chu.factures VALUES (14, 14, 13918.00, 0.00, 'PAYEE', DATE '2026-09-19');
INSERT INTO chu.sejours VALUES (15, 36, 40, 4, DATE '2026-09-15', DATE '2026-09-23', 'Chimiothérapie');
INSERT INTO chu.dossiers_medicaux VALUES (15, 15, 'Lymphome', 'Aucun', 'Protocole R-CHOP', 'O', DATE '2026-09-23');
INSERT INTO chu.prescriptions VALUES (30, 15, 4, 'Ondansétron', '1 inj/j', DATE '2026-09-15', 'ANNULEE');
INSERT INTO chu.factures VALUES (15, 15, 30855.00, 21598.50, 'EMISE', DATE '2026-09-23');
INSERT INTO chu.sejours VALUES (16, 9, 10, 1, DATE '2026-09-18', DATE '2026-09-19', 'Traumatisme');
INSERT INTO chu.dossiers_medicaux VALUES (16, 16, 'Fracture du radius', 'Diabète type 2', 'Plâtre + antalgiques', 'N', DATE '2026-09-19');
INSERT INTO chu.prescriptions VALUES (31, 16, 1, 'Paracétamol', '1 cp x 3/j', DATE '2026-09-18', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (32, 16, 1, 'Héparine', '2 cp/j', DATE '2026-09-19', 'PRESCRITE');
INSERT INTO chu.factures VALUES (16, 16, 1792.00, 1433.60, 'PAYEE', DATE '2026-09-19');
INSERT INTO chu.sejours VALUES (17, 22, 20, 6, DATE '2026-09-21', DATE '2026-09-23', 'Hypertension sévère');
INSERT INTO chu.dossiers_medicaux VALUES (17, 17, 'HTA', 'HTA', 'IEC', 'N', DATE '2026-09-23');
INSERT INTO chu.prescriptions VALUES (33, 17, 6, 'Apixaban', '2 cp/j', DATE '2026-09-21', 'PRESCRITE');
INSERT INTO chu.prescriptions VALUES (34, 17, 6, 'Ramipril', '5 ml x 2/j', DATE '2026-09-22', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (35, 17, 6, 'Bisoprolol', '1 inj/j', DATE '2026-09-23', 'ANNULEE');
INSERT INTO chu.factures VALUES (17, 17, 2729.00, 1910.30, 'PAYEE', DATE '2026-09-23');
INSERT INTO chu.sejours VALUES (18, 35, 30, 3, DATE '2026-09-24', NULL, 'Bronchiolite');
INSERT INTO chu.dossiers_medicaux VALUES (18, 18, 'Bronchiolite', 'Asthme', 'Kinésithérapie respiratoire', 'N', DATE '2026-09-24');
INSERT INTO chu.prescriptions VALUES (36, 18, 3, 'Paracétamol sirop', '5 ml x 2/j', DATE '2026-09-24', 'DELIVREE');
INSERT INTO chu.factures VALUES (18, 18, 3666.00, 0.00, 'EMISE', DATE '2026-09-24');
INSERT INTO chu.sejours VALUES (19, 8, 40, 4, DATE '2026-08-03', DATE '2026-08-07', 'Bilan tumoral');
INSERT INTO chu.dossiers_medicaux VALUES (19, 19, 'Cancer du sein', 'Tabagisme', 'Protocole AC-T', 'O', DATE '2026-08-07');
INSERT INTO chu.prescriptions VALUES (37, 19, 4, 'Dexaméthasone', '1 inj/j', DATE '2026-08-03', 'ANNULEE');
INSERT INTO chu.prescriptions VALUES (38, 19, 4, 'Morphine', '1 cp x 3/j', DATE '2026-08-04', 'DELIVREE');
INSERT INTO chu.factures VALUES (19, 19, 34603.00, 24222.10, 'PAYEE', DATE '2026-08-07');
INSERT INTO chu.sejours VALUES (20, 21, 10, 1, DATE '2026-08-06', DATE '2026-08-11', 'Traumatisme');
INSERT INTO chu.dossiers_medicaux VALUES (20, 20, 'Fracture du radius', 'Aucun', 'Plâtre + antalgiques', 'N', DATE '2026-08-11');
INSERT INTO chu.prescriptions VALUES (39, 20, 1, 'Paracétamol', '1 cp x 3/j', DATE '2026-08-06', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (40, 20, 1, 'Héparine', '2 cp/j', DATE '2026-08-07', 'PRESCRITE');
INSERT INTO chu.prescriptions VALUES (41, 20, 1, 'Amoxicilline', '5 ml x 2/j', DATE '2026-08-08', 'DELIVREE');
INSERT INTO chu.factures VALUES (20, 20, 5540.00, 4432.00, 'PAYEE', DATE '2026-08-11');
INSERT INTO chu.sejours VALUES (21, 34, 20, 6, DATE '2026-08-09', DATE '2026-08-15', 'Insuffisance cardiaque');
INSERT INTO chu.dossiers_medicaux VALUES (21, 21, 'Insuffisance cardiaque', 'Diabète type 2', 'Furosémide', 'N', DATE '2026-08-15');
INSERT INTO chu.prescriptions VALUES (42, 21, 6, 'Apixaban', '2 cp/j', DATE '2026-08-09', 'PRESCRITE');
INSERT INTO chu.factures VALUES (21, 21, 6477.00, 4533.90, 'EMISE', DATE '2026-08-15');
INSERT INTO chu.sejours VALUES (22, 7, 30, 3, DATE '2026-08-12', DATE '2026-08-19', 'Gastro-entérite');
INSERT INTO chu.dossiers_medicaux VALUES (22, 22, 'Déshydratation', 'HTA', 'Réhydratation', 'O', DATE '2026-08-19');
INSERT INTO chu.prescriptions VALUES (43, 22, 3, 'Salbutamol', '5 ml x 2/j', DATE '2026-08-12', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (44, 22, 3, 'SRO', '1 inj/j', DATE '2026-08-13', 'ANNULEE');
INSERT INTO chu.factures VALUES (22, 22, 7414.00, 0.00, 'PAYEE', DATE '2026-08-19');
INSERT INTO chu.sejours VALUES (23, 20, 40, 4, DATE '2026-08-15', DATE '2026-08-23', 'Radiothérapie');
INSERT INTO chu.dossiers_medicaux VALUES (23, 23, 'Cancer colorectal', 'Asthme', 'Protocole FOLFOX', 'O', DATE '2026-08-23');
INSERT INTO chu.prescriptions VALUES (45, 23, 4, 'Morphine', '1 inj/j', DATE '2026-08-15', 'ANNULEE');
INSERT INTO chu.prescriptions VALUES (46, 23, 4, 'Ondansétron', '1 cp x 3/j', DATE '2026-08-16', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (47, 23, 4, 'Dexaméthasone', '2 cp/j', DATE '2026-08-17', 'PRESCRITE');
INSERT INTO chu.factures VALUES (23, 23, 38351.00, 26845.70, 'PAYEE', DATE '2026-08-23');
INSERT INTO chu.sejours VALUES (24, 33, 10, 1, DATE '2026-08-18', DATE '2026-08-19', 'Traumatisme');
INSERT INTO chu.dossiers_medicaux VALUES (24, 24, 'Fracture du radius', 'Tabagisme', 'Plâtre + antalgiques', 'N', DATE '2026-08-19');
INSERT INTO chu.prescriptions VALUES (48, 24, 1, 'Paracétamol', '1 cp x 3/j', DATE '2026-08-18', 'DELIVREE');
INSERT INTO chu.factures VALUES (24, 24, 9288.00, 7430.40, 'EMISE', DATE '2026-08-19');
INSERT INTO chu.sejours VALUES (25, 6, 20, 6, DATE '2026-08-21', DATE '2026-08-23', 'Arythmie');
INSERT INTO chu.dossiers_medicaux VALUES (25, 25, 'Fibrillation auriculaire', 'Aucun', 'Anticoagulant', 'N', DATE '2026-08-23');
INSERT INTO chu.prescriptions VALUES (49, 25, 6, 'Apixaban', '2 cp/j', DATE '2026-08-21', 'PRESCRITE');
INSERT INTO chu.prescriptions VALUES (50, 25, 6, 'Ramipril', '5 ml x 2/j', DATE '2026-08-22', 'DELIVREE');
INSERT INTO chu.factures VALUES (25, 25, 10225.00, 7157.50, 'PAYEE', DATE '2026-08-23');
INSERT INTO chu.sejours VALUES (26, 19, 30, 3, DATE '2026-08-24', DATE '2026-08-27', 'Asthme');
INSERT INTO chu.dossiers_medicaux VALUES (26, 26, 'Asthme aigu', 'Diabète type 2', 'Salbutamol', 'N', DATE '2026-08-27');
INSERT INTO chu.prescriptions VALUES (51, 26, 3, 'SRO', '5 ml x 2/j', DATE '2026-08-24', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (52, 26, 3, 'Paracétamol sirop', '1 inj/j', DATE '2026-08-25', 'ANNULEE');
INSERT INTO chu.prescriptions VALUES (53, 26, 3, 'Salbutamol', '1 cp x 3/j', DATE '2026-08-26', 'DELIVREE');
INSERT INTO chu.factures VALUES (26, 26, 11162.00, 0.00, 'PAYEE', DATE '2026-08-27');
INSERT INTO chu.sejours VALUES (27, 32, 40, 4, DATE '2026-08-27', NULL, 'Chimiothérapie');
INSERT INTO chu.dossiers_medicaux VALUES (27, 27, 'Lymphome', 'HTA', 'Protocole R-CHOP', 'O', DATE '2026-08-27');
INSERT INTO chu.prescriptions VALUES (54, 27, 4, 'Ondansétron', '1 inj/j', DATE '2026-08-27', 'ANNULEE');
INSERT INTO chu.factures VALUES (27, 27, 42099.00, 29469.30, 'EMISE', DATE '2026-08-27');
INSERT INTO chu.sejours VALUES (28, 5, 10, 1, DATE '2026-08-30', DATE '2026-09-04', 'Traumatisme');
INSERT INTO chu.dossiers_medicaux VALUES (28, 28, 'Fracture du radius', 'Asthme', 'Plâtre + antalgiques', 'N', DATE '2026-09-04');
INSERT INTO chu.prescriptions VALUES (55, 28, 1, 'Paracétamol', '1 cp x 3/j', DATE '2026-08-30', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (56, 28, 1, 'Héparine', '2 cp/j', DATE '2026-08-31', 'PRESCRITE');
INSERT INTO chu.factures VALUES (28, 28, 13036.00, 10428.80, 'PAYEE', DATE '2026-09-04');
INSERT INTO chu.sejours VALUES (29, 18, 20, 6, DATE '2026-09-02', DATE '2026-09-08', 'Hypertension sévère');
INSERT INTO chu.dossiers_medicaux VALUES (29, 29, 'HTA', 'Tabagisme', 'IEC', 'N', DATE '2026-09-08');
INSERT INTO chu.prescriptions VALUES (57, 29, 6, 'Apixaban', '2 cp/j', DATE '2026-09-02', 'PRESCRITE');
INSERT INTO chu.prescriptions VALUES (58, 29, 6, 'Ramipril', '5 ml x 2/j', DATE '2026-09-03', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (59, 29, 6, 'Bisoprolol', '1 inj/j', DATE '2026-09-04', 'ANNULEE');
INSERT INTO chu.factures VALUES (29, 29, 13973.00, 9781.10, 'PAYEE', DATE '2026-09-08');
INSERT INTO chu.sejours VALUES (30, 31, 30, 3, DATE '2026-09-05', DATE '2026-09-12', 'Bronchiolite');
INSERT INTO chu.dossiers_medicaux VALUES (30, 30, 'Bronchiolite', 'Aucun', 'Kinésithérapie respiratoire', 'O', DATE '2026-09-12');
INSERT INTO chu.prescriptions VALUES (60, 30, 3, 'Paracétamol sirop', '5 ml x 2/j', DATE '2026-09-05', 'DELIVREE');
INSERT INTO chu.factures VALUES (30, 30, 910.00, 0.00, 'EMISE', DATE '2026-09-12');
INSERT INTO chu.sejours VALUES (31, 4, 40, 4, DATE '2026-09-08', DATE '2026-09-16', 'Bilan tumoral');
INSERT INTO chu.dossiers_medicaux VALUES (31, 31, 'Cancer du sein', 'Diabète type 2', 'Protocole AC-T', 'O', DATE '2026-09-16');
INSERT INTO chu.prescriptions VALUES (61, 31, 4, 'Dexaméthasone', '1 inj/j', DATE '2026-09-08', 'ANNULEE');
INSERT INTO chu.prescriptions VALUES (62, 31, 4, 'Morphine', '1 cp x 3/j', DATE '2026-09-09', 'DELIVREE');
INSERT INTO chu.factures VALUES (31, 31, 31847.00, 22292.90, 'PAYEE', DATE '2026-09-16');
INSERT INTO chu.sejours VALUES (32, 17, 10, 1, DATE '2026-09-11', DATE '2026-09-12', 'Traumatisme');
INSERT INTO chu.dossiers_medicaux VALUES (32, 32, 'Fracture du radius', 'HTA', 'Plâtre + antalgiques', 'N', DATE '2026-09-12');
INSERT INTO chu.prescriptions VALUES (63, 32, 1, 'Paracétamol', '1 cp x 3/j', DATE '2026-09-11', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (64, 32, 1, 'Héparine', '2 cp/j', DATE '2026-09-12', 'PRESCRITE');
INSERT INTO chu.prescriptions VALUES (65, 32, 1, 'Amoxicilline', '5 ml x 2/j', DATE '2026-09-13', 'DELIVREE');
INSERT INTO chu.factures VALUES (32, 32, 2784.00, 2227.20, 'PAYEE', DATE '2026-09-12');
INSERT INTO chu.sejours VALUES (33, 30, 20, 6, DATE '2026-09-14', DATE '2026-09-16', 'Insuffisance cardiaque');
INSERT INTO chu.dossiers_medicaux VALUES (33, 33, 'Insuffisance cardiaque', 'Asthme', 'Furosémide', 'N', DATE '2026-09-16');
INSERT INTO chu.prescriptions VALUES (66, 33, 6, 'Apixaban', '2 cp/j', DATE '2026-09-14', 'PRESCRITE');
INSERT INTO chu.factures VALUES (33, 33, 3721.00, 2604.70, 'EMISE', DATE '2026-09-16');
INSERT INTO chu.sejours VALUES (34, 3, 30, 3, DATE '2026-09-17', DATE '2026-09-20', 'Gastro-entérite');
INSERT INTO chu.dossiers_medicaux VALUES (34, 34, 'Déshydratation', 'Tabagisme', 'Réhydratation', 'N', DATE '2026-09-20');
INSERT INTO chu.prescriptions VALUES (67, 34, 3, 'Salbutamol', '5 ml x 2/j', DATE '2026-09-17', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (68, 34, 3, 'SRO', '1 inj/j', DATE '2026-09-18', 'ANNULEE');
INSERT INTO chu.factures VALUES (34, 34, 4658.00, 0.00, 'PAYEE', DATE '2026-09-20');
INSERT INTO chu.sejours VALUES (35, 16, 40, 4, DATE '2026-09-20', DATE '2026-09-24', 'Radiothérapie');
INSERT INTO chu.dossiers_medicaux VALUES (35, 35, 'Cancer colorectal', 'Aucun', 'Protocole FOLFOX', 'O', DATE '2026-09-24');
INSERT INTO chu.prescriptions VALUES (69, 35, 4, 'Morphine', '1 inj/j', DATE '2026-09-20', 'ANNULEE');
INSERT INTO chu.prescriptions VALUES (70, 35, 4, 'Ondansétron', '1 cp x 3/j', DATE '2026-09-21', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (71, 35, 4, 'Dexaméthasone', '2 cp/j', DATE '2026-09-22', 'PRESCRITE');
INSERT INTO chu.factures VALUES (35, 35, 35595.00, 24916.50, 'PAYEE', DATE '2026-09-24');
INSERT INTO chu.sejours VALUES (36, 29, 10, 1, DATE '2026-09-23', NULL, 'Traumatisme');
INSERT INTO chu.dossiers_medicaux VALUES (36, 36, 'Fracture du radius', 'Diabète type 2', 'Plâtre + antalgiques', 'N', DATE '2026-09-23');
INSERT INTO chu.prescriptions VALUES (72, 36, 1, 'Paracétamol', '1 cp x 3/j', DATE '2026-09-23', 'DELIVREE');
INSERT INTO chu.factures VALUES (36, 36, 6532.00, 5225.60, 'EMISE', DATE '2026-09-23');
INSERT INTO chu.sejours VALUES (37, 2, 20, 6, DATE '2026-08-02', DATE '2026-08-08', 'Arythmie');
INSERT INTO chu.dossiers_medicaux VALUES (37, 37, 'Fibrillation auriculaire', 'HTA', 'Anticoagulant', 'N', DATE '2026-08-08');
INSERT INTO chu.prescriptions VALUES (73, 37, 6, 'Apixaban', '2 cp/j', DATE '2026-08-02', 'PRESCRITE');
INSERT INTO chu.prescriptions VALUES (74, 37, 6, 'Ramipril', '5 ml x 2/j', DATE '2026-08-03', 'DELIVREE');
INSERT INTO chu.factures VALUES (37, 37, 7469.00, 5228.30, 'PAYEE', DATE '2026-08-08');
INSERT INTO chu.sejours VALUES (38, 15, 30, 3, DATE '2026-08-05', DATE '2026-08-12', 'Asthme');
INSERT INTO chu.dossiers_medicaux VALUES (38, 38, 'Asthme aigu', 'Asthme', 'Salbutamol', 'N', DATE '2026-08-12');
INSERT INTO chu.prescriptions VALUES (75, 38, 3, 'SRO', '5 ml x 2/j', DATE '2026-08-05', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (76, 38, 3, 'Paracétamol sirop', '1 inj/j', DATE '2026-08-06', 'ANNULEE');
INSERT INTO chu.prescriptions VALUES (77, 38, 3, 'Salbutamol', '1 cp x 3/j', DATE '2026-08-07', 'DELIVREE');
INSERT INTO chu.factures VALUES (38, 38, 8406.00, 0.00, 'PAYEE', DATE '2026-08-12');
INSERT INTO chu.sejours VALUES (39, 28, 40, 4, DATE '2026-08-08', DATE '2026-08-16', 'Chimiothérapie');
INSERT INTO chu.dossiers_medicaux VALUES (39, 39, 'Lymphome', 'Tabagisme', 'Protocole R-CHOP', 'O', DATE '2026-08-16');
INSERT INTO chu.prescriptions VALUES (78, 39, 4, 'Ondansétron', '1 inj/j', DATE '2026-08-08', 'ANNULEE');
INSERT INTO chu.factures VALUES (39, 39, 39343.00, 27540.10, 'EMISE', DATE '2026-08-16');
INSERT INTO chu.sejours VALUES (40, 1, 10, 1, DATE '2026-08-11', DATE '2026-08-12', 'Traumatisme');
INSERT INTO chu.dossiers_medicaux VALUES (40, 40, 'Fracture du radius', 'Aucun', 'Plâtre + antalgiques', 'N', DATE '2026-08-12');
INSERT INTO chu.prescriptions VALUES (79, 40, 1, 'Paracétamol', '1 cp x 3/j', DATE '2026-08-11', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (80, 40, 1, 'Héparine', '2 cp/j', DATE '2026-08-12', 'PRESCRITE');
INSERT INTO chu.factures VALUES (40, 40, 10280.00, 8224.00, 'PAYEE', DATE '2026-08-12');
INSERT INTO chu.sejours VALUES (41, 14, 20, 6, DATE '2026-08-14', DATE '2026-08-16', 'Hypertension sévère');
INSERT INTO chu.dossiers_medicaux VALUES (41, 41, 'HTA', 'Diabète type 2', 'IEC', 'N', DATE '2026-08-16');
INSERT INTO chu.prescriptions VALUES (81, 41, 6, 'Apixaban', '2 cp/j', DATE '2026-08-14', 'PRESCRITE');
INSERT INTO chu.prescriptions VALUES (82, 41, 6, 'Ramipril', '5 ml x 2/j', DATE '2026-08-15', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (83, 41, 6, 'Bisoprolol', '1 inj/j', DATE '2026-08-16', 'ANNULEE');
INSERT INTO chu.factures VALUES (41, 41, 11217.00, 7851.90, 'PAYEE', DATE '2026-08-16');
INSERT INTO chu.sejours VALUES (42, 27, 30, 3, DATE '2026-08-17', DATE '2026-08-20', 'Bronchiolite');
INSERT INTO chu.dossiers_medicaux VALUES (42, 42, 'Bronchiolite', 'HTA', 'Kinésithérapie respiratoire', 'N', DATE '2026-08-20');
INSERT INTO chu.prescriptions VALUES (84, 42, 3, 'Paracétamol sirop', '5 ml x 2/j', DATE '2026-08-17', 'DELIVREE');
INSERT INTO chu.factures VALUES (42, 42, 12154.00, 0.00, 'EMISE', DATE '2026-08-20');
INSERT INTO chu.sejours VALUES (43, 40, 40, 4, DATE '2026-08-20', DATE '2026-08-24', 'Bilan tumoral');
INSERT INTO chu.dossiers_medicaux VALUES (43, 43, 'Cancer du sein', 'Asthme', 'Protocole AC-T', 'O', DATE '2026-08-24');
INSERT INTO chu.prescriptions VALUES (85, 43, 4, 'Dexaméthasone', '1 inj/j', DATE '2026-08-20', 'ANNULEE');
INSERT INTO chu.prescriptions VALUES (86, 43, 4, 'Morphine', '1 cp x 3/j', DATE '2026-08-21', 'DELIVREE');
INSERT INTO chu.factures VALUES (43, 43, 43091.00, 30163.70, 'PAYEE', DATE '2026-08-24');
INSERT INTO chu.sejours VALUES (44, 13, 10, 1, DATE '2026-08-23', DATE '2026-08-28', 'Traumatisme');
INSERT INTO chu.dossiers_medicaux VALUES (44, 44, 'Fracture du radius', 'Tabagisme', 'Plâtre + antalgiques', 'N', DATE '2026-08-28');
INSERT INTO chu.prescriptions VALUES (87, 44, 1, 'Paracétamol', '1 cp x 3/j', DATE '2026-08-23', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (88, 44, 1, 'Héparine', '2 cp/j', DATE '2026-08-24', 'PRESCRITE');
INSERT INTO chu.prescriptions VALUES (89, 44, 1, 'Amoxicilline', '5 ml x 2/j', DATE '2026-08-25', 'DELIVREE');
INSERT INTO chu.factures VALUES (44, 44, 14028.00, 11222.40, 'PAYEE', DATE '2026-08-28');
INSERT INTO chu.sejours VALUES (45, 26, 20, 6, DATE '2026-08-26', NULL, 'Insuffisance cardiaque');
INSERT INTO chu.dossiers_medicaux VALUES (45, 45, 'Insuffisance cardiaque', 'Aucun', 'Furosémide', 'N', DATE '2026-08-26');
INSERT INTO chu.prescriptions VALUES (90, 45, 6, 'Apixaban', '2 cp/j', DATE '2026-08-26', 'PRESCRITE');
INSERT INTO chu.factures VALUES (45, 45, 965.00, 675.50, 'EMISE', DATE '2026-08-26');
INSERT INTO chu.sejours VALUES (46, 39, 30, 3, DATE '2026-08-29', DATE '2026-09-05', 'Gastro-entérite');
INSERT INTO chu.dossiers_medicaux VALUES (46, 46, 'Déshydratation', 'Diabète type 2', 'Réhydratation', 'N', DATE '2026-09-05');
INSERT INTO chu.prescriptions VALUES (91, 46, 3, 'Salbutamol', '5 ml x 2/j', DATE '2026-08-29', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (92, 46, 3, 'SRO', '1 inj/j', DATE '2026-08-30', 'ANNULEE');
INSERT INTO chu.factures VALUES (46, 46, 1902.00, 0.00, 'PAYEE', DATE '2026-09-05');
INSERT INTO chu.sejours VALUES (47, 12, 40, 4, DATE '2026-09-01', DATE '2026-09-09', 'Radiothérapie');
INSERT INTO chu.dossiers_medicaux VALUES (47, 47, 'Cancer colorectal', 'HTA', 'Protocole FOLFOX', 'O', DATE '2026-09-09');
INSERT INTO chu.prescriptions VALUES (93, 47, 4, 'Morphine', '1 inj/j', DATE '2026-09-01', 'ANNULEE');
INSERT INTO chu.prescriptions VALUES (94, 47, 4, 'Ondansétron', '1 cp x 3/j', DATE '2026-09-02', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (95, 47, 4, 'Dexaméthasone', '2 cp/j', DATE '2026-09-03', 'PRESCRITE');
INSERT INTO chu.factures VALUES (47, 47, 32839.00, 22987.30, 'PAYEE', DATE '2026-09-09');
INSERT INTO chu.sejours VALUES (48, 25, 10, 1, DATE '2026-09-04', DATE '2026-09-05', 'Traumatisme');
INSERT INTO chu.dossiers_medicaux VALUES (48, 48, 'Fracture du radius', 'Asthme', 'Plâtre + antalgiques', 'N', DATE '2026-09-05');
INSERT INTO chu.prescriptions VALUES (96, 48, 1, 'Paracétamol', '1 cp x 3/j', DATE '2026-09-04', 'DELIVREE');
INSERT INTO chu.factures VALUES (48, 48, 3776.00, 3020.80, 'EMISE', DATE '2026-09-05');
INSERT INTO chu.sejours VALUES (49, 38, 20, 6, DATE '2026-09-07', DATE '2026-09-09', 'Arythmie');
INSERT INTO chu.dossiers_medicaux VALUES (49, 49, 'Fibrillation auriculaire', 'Tabagisme', 'Anticoagulant', 'N', DATE '2026-09-09');
INSERT INTO chu.prescriptions VALUES (97, 49, 6, 'Apixaban', '2 cp/j', DATE '2026-09-07', 'PRESCRITE');
INSERT INTO chu.prescriptions VALUES (98, 49, 6, 'Ramipril', '5 ml x 2/j', DATE '2026-09-08', 'DELIVREE');
INSERT INTO chu.factures VALUES (49, 49, 4713.00, 3299.10, 'PAYEE', DATE '2026-09-09');
INSERT INTO chu.sejours VALUES (50, 11, 30, 3, DATE '2026-09-10', DATE '2026-09-13', 'Asthme');
INSERT INTO chu.dossiers_medicaux VALUES (50, 50, 'Asthme aigu', 'Aucun', 'Salbutamol', 'N', DATE '2026-09-13');
INSERT INTO chu.prescriptions VALUES (99, 50, 3, 'SRO', '5 ml x 2/j', DATE '2026-09-10', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (100, 50, 3, 'Paracétamol sirop', '1 inj/j', DATE '2026-09-11', 'ANNULEE');
INSERT INTO chu.prescriptions VALUES (101, 50, 3, 'Salbutamol', '1 cp x 3/j', DATE '2026-09-12', 'DELIVREE');
INSERT INTO chu.factures VALUES (50, 50, 5650.00, 0.00, 'PAYEE', DATE '2026-09-13');
INSERT INTO chu.sejours VALUES (51, 24, 40, 4, DATE '2026-09-13', DATE '2026-09-17', 'Chimiothérapie');
INSERT INTO chu.dossiers_medicaux VALUES (51, 51, 'Lymphome', 'Diabète type 2', 'Protocole R-CHOP', 'O', DATE '2026-09-17');
INSERT INTO chu.prescriptions VALUES (102, 51, 4, 'Ondansétron', '1 inj/j', DATE '2026-09-13', 'ANNULEE');
INSERT INTO chu.factures VALUES (51, 51, 36587.00, 25610.90, 'EMISE', DATE '2026-09-17');
INSERT INTO chu.sejours VALUES (52, 37, 10, 1, DATE '2026-09-16', DATE '2026-09-21', 'Traumatisme');
INSERT INTO chu.dossiers_medicaux VALUES (52, 52, 'Fracture du radius', 'HTA', 'Plâtre + antalgiques', 'N', DATE '2026-09-21');
INSERT INTO chu.prescriptions VALUES (103, 52, 1, 'Paracétamol', '1 cp x 3/j', DATE '2026-09-16', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (104, 52, 1, 'Héparine', '2 cp/j', DATE '2026-09-17', 'PRESCRITE');
INSERT INTO chu.factures VALUES (52, 52, 7524.00, 6019.20, 'PAYEE', DATE '2026-09-21');
INSERT INTO chu.sejours VALUES (53, 10, 20, 6, DATE '2026-09-19', DATE '2026-09-25', 'Hypertension sévère');
INSERT INTO chu.dossiers_medicaux VALUES (53, 53, 'HTA', 'Asthme', 'IEC', 'N', DATE '2026-09-25');
INSERT INTO chu.prescriptions VALUES (105, 53, 6, 'Apixaban', '2 cp/j', DATE '2026-09-19', 'PRESCRITE');
INSERT INTO chu.prescriptions VALUES (106, 53, 6, 'Ramipril', '5 ml x 2/j', DATE '2026-09-20', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (107, 53, 6, 'Bisoprolol', '1 inj/j', DATE '2026-09-21', 'ANNULEE');
INSERT INTO chu.factures VALUES (53, 53, 8461.00, 5922.70, 'PAYEE', DATE '2026-09-25');
INSERT INTO chu.sejours VALUES (54, 23, 30, 3, DATE '2026-09-22', NULL, 'Bronchiolite');
INSERT INTO chu.dossiers_medicaux VALUES (54, 54, 'Bronchiolite', 'Tabagisme', 'Kinésithérapie respiratoire', 'O', DATE '2026-09-22');
INSERT INTO chu.prescriptions VALUES (108, 54, 3, 'Paracétamol sirop', '5 ml x 2/j', DATE '2026-09-22', 'DELIVREE');
INSERT INTO chu.factures VALUES (54, 54, 9398.00, 0.00, 'EMISE', DATE '2026-09-22');
INSERT INTO chu.sejours VALUES (55, 36, 40, 4, DATE '2026-08-01', DATE '2026-08-09', 'Bilan tumoral');
INSERT INTO chu.dossiers_medicaux VALUES (55, 55, 'Cancer du sein', 'Aucun', 'Protocole AC-T', 'O', DATE '2026-08-09');
INSERT INTO chu.prescriptions VALUES (109, 55, 4, 'Dexaméthasone', '1 inj/j', DATE '2026-08-01', 'ANNULEE');
INSERT INTO chu.prescriptions VALUES (110, 55, 4, 'Morphine', '1 cp x 3/j', DATE '2026-08-02', 'DELIVREE');
INSERT INTO chu.factures VALUES (55, 55, 40335.00, 28234.50, 'PAYEE', DATE '2026-08-09');
INSERT INTO chu.sejours VALUES (56, 9, 10, 1, DATE '2026-08-04', DATE '2026-08-05', 'Traumatisme');
INSERT INTO chu.dossiers_medicaux VALUES (56, 56, 'Fracture du radius', 'Diabète type 2', 'Plâtre + antalgiques', 'N', DATE '2026-08-05');
INSERT INTO chu.prescriptions VALUES (111, 56, 1, 'Paracétamol', '1 cp x 3/j', DATE '2026-08-04', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (112, 56, 1, 'Héparine', '2 cp/j', DATE '2026-08-05', 'PRESCRITE');
INSERT INTO chu.prescriptions VALUES (113, 56, 1, 'Amoxicilline', '5 ml x 2/j', DATE '2026-08-06', 'DELIVREE');
INSERT INTO chu.factures VALUES (56, 56, 11272.00, 9017.60, 'PAYEE', DATE '2026-08-05');
INSERT INTO chu.sejours VALUES (57, 22, 20, 6, DATE '2026-08-07', DATE '2026-08-09', 'Insuffisance cardiaque');
INSERT INTO chu.dossiers_medicaux VALUES (57, 57, 'Insuffisance cardiaque', 'HTA', 'Furosémide', 'N', DATE '2026-08-09');
INSERT INTO chu.prescriptions VALUES (114, 57, 6, 'Apixaban', '2 cp/j', DATE '2026-08-07', 'PRESCRITE');
INSERT INTO chu.factures VALUES (57, 57, 12209.00, 8546.30, 'EMISE', DATE '2026-08-09');
INSERT INTO chu.sejours VALUES (58, 35, 30, 3, DATE '2026-08-10', DATE '2026-08-13', 'Gastro-entérite');
INSERT INTO chu.dossiers_medicaux VALUES (58, 58, 'Déshydratation', 'Asthme', 'Réhydratation', 'N', DATE '2026-08-13');
INSERT INTO chu.prescriptions VALUES (115, 58, 3, 'Salbutamol', '5 ml x 2/j', DATE '2026-08-10', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (116, 58, 3, 'SRO', '1 inj/j', DATE '2026-08-11', 'ANNULEE');
INSERT INTO chu.factures VALUES (58, 58, 13146.00, 0.00, 'PAYEE', DATE '2026-08-13');
INSERT INTO chu.sejours VALUES (59, 8, 40, 4, DATE '2026-08-13', DATE '2026-08-17', 'Radiothérapie');
INSERT INTO chu.dossiers_medicaux VALUES (59, 59, 'Cancer colorectal', 'Tabagisme', 'Protocole FOLFOX', 'O', DATE '2026-08-17');
INSERT INTO chu.prescriptions VALUES (117, 59, 4, 'Morphine', '1 inj/j', DATE '2026-08-13', 'ANNULEE');
INSERT INTO chu.prescriptions VALUES (118, 59, 4, 'Ondansétron', '1 cp x 3/j', DATE '2026-08-14', 'DELIVREE');
INSERT INTO chu.prescriptions VALUES (119, 59, 4, 'Dexaméthasone', '2 cp/j', DATE '2026-08-15', 'PRESCRITE');
INSERT INTO chu.factures VALUES (59, 59, 44083.00, 30858.10, 'PAYEE', DATE '2026-08-17');
INSERT INTO chu.sejours VALUES (60, 21, 10, 1, DATE '2026-08-16', DATE '2026-08-21', 'Traumatisme');
INSERT INTO chu.dossiers_medicaux VALUES (60, 60, 'Fracture du radius', 'Aucun', 'Plâtre + antalgiques', 'N', DATE '2026-08-21');
INSERT INTO chu.prescriptions VALUES (120, 60, 1, 'Paracétamol', '1 cp x 3/j', DATE '2026-08-16', 'DELIVREE');
INSERT INTO chu.factures VALUES (60, 60, 1020.00, 816.00, 'EMISE', DATE '2026-08-21');
COMMIT;

-- Vue réservée à la direction : statistiques, sans aucune donnée nominative
CREATE VIEW chu.v_stats_services AS
  SELECT sv.nom AS service, COUNT(s.sejour_id) AS nb_sejours,
         ROUND(AVG(NVL(s.date_sortie, SYSDATE) - s.date_entree), 1) AS dms_jours,
         SUM(f.montant) AS ca_factures
  FROM   chu.services sv
  LEFT JOIN chu.sejours s  ON s.service_id = sv.service_id
  LEFT JOIN chu.factures f ON f.sejour_id = s.sejour_id
  GROUP  BY sv.nom;

-- Vue du secrétariat : identité et séjours, sans données médicales
CREATE VIEW chu.v_accueil AS
  SELECT s.sejour_id, p.patient_id, p.nom, p.prenom, p.date_naissance, p.telephone,
         p.mutuelle, sv.nom AS service, s.date_entree, s.date_sortie
  FROM   chu.sejours s JOIN chu.patients p  ON p.patient_id = s.patient_id
                       JOIN chu.services sv ON sv.service_id = s.service_id;

-- Vue des infirmiers : dossiers NON confidentiels uniquement
CREATE VIEW chu.v_soins AS
  SELECT d.dossier_id, s.sejour_id, p.nom, p.prenom, sv.nom AS service,
         d.diagnostic, d.traitement
  FROM   chu.dossiers_medicaux d JOIN chu.sejours s  ON s.sejour_id = d.sejour_id
                                 JOIN chu.patients p  ON p.patient_id = s.patient_id
                                 JOIN chu.services sv ON sv.service_id = s.service_id
  WHERE  d.confidentiel = 'N';

