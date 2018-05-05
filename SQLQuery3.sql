IF NOT EXISTS(SELECT * FROM master.sys.databases 
          WHERE name='LV_310_DENTISTRY')
BEGIN
    CREATE DATABASE LV_310_DENTISTRY
END;

GO

USE LV_310_DENTISTRY;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = 'USERS')
BEGIN
	CREATE TABLE USERS(ID_USER INT NOT NULL,
	FIRSTNAME VARCHAR(30) NOT NULL,
	LASTNAME VARCHAR(30) NOT NULL,
	PHONENUM BIGINT NOT NULL,
	USER_PASSWORD VARCHAR(15) NOT NULL,
	CONSTRAINT PK_USERS PRIMARY KEY (ID_USER))
END;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = 'DOCTORS')
BEGIN
	CREATE TABLE DOCTORS(ID_DOCTOR INT NOT NULL,
	FIRSTNAME VARCHAR(30) NOT NULL,
	LASTNAME VARCHAR(30) NOT NULL,
	PHONENUM BIGINT NOT NULL,
	CABNUM TINYINT NOT NULL,
	SPECIALITY VARCHAR(30) NOT NULL,
	DOC_PASSWORD VARCHAR(15) NOT NULL,
	CONSTRAINT PK_DOCTORS PRIMARY KEY (ID_DOCTOR))
END;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = 'USER_DOCTOR')
BEGIN
	CREATE TABLE USER_DOCTOR(USER_ID INT NOT NULL,
	DOCTOR_ID INT NOT NULL,
	CONSTRAINT FK_USER_DOCTOR_USERS FOREIGN KEY(USER_ID)
	REFERENCES USERS(ID_USER),
	CONSTRAINT FK_USER_DOCTOR_DOCTORS FOREIGN KEY(DOCTOR_ID)
	REFERENCES DOCTORS(ID_DOCTOR))
END;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = 'TIMESLOT')
BEGIN
	CREATE TABLE TIMESLOT(ID INT NOT NULL,
	DAY_OF_WEEK VARCHAR(10) NOT NULL,
	START_WORKHOUR INT NOT NULL,
	END_WORKHOUR INT NOT NULL,
	CONSTRAINT PK_TIMESLOT PRIMARY KEY (ID))
END;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = 'DOC_TIMESLOT')
BEGIN
	CREATE TABLE DOC_TIMESLOT(DOCTOR_ID INT NOT NULL,
	TIMESLOT_ID INT NOT NULL,
	CONSTRAINT FK_DOC_TIMESLOT_DOCTORS FOREIGN KEY(DOCTOR_ID)
	REFERENCES DOCTORS(ID_DOCTOR),
	CONSTRAINT FK_DOC_TIMESLOT_TIMESLOT FOREIGN KEY(TIMESLOT_ID)
	REFERENCES TIMESLOT(ID))
END;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = 'DOC_RECEPTION')
BEGIN
	CREATE TABLE DOC_RECEPTION(DOCTOR_ID INT NOT NULL,
	USER_ID INT NOT NULL,
	RECEPTION_TIME INT NOT NULL,
	CONSTRAINT FK_DOC_RECEPTION_DOCTORS FOREIGN KEY(DOCTOR_ID)
	REFERENCES DOCTORS(ID_DOCTOR),
	CONSTRAINT FK_DOC_RECEPTION_USERS FOREIGN KEY(USER_ID)
	REFERENCES USERS(ID_USER))
END;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = 'PATIENTCARDS')
BEGIN
	CREATE TABLE PATIENTCARDS(DOCTOR_ID INT NOT NULL,
	USER_ID INT NOT NULL,
	NOTE_ID INT NOT NULL,
	CONSTRAINT FK_PATIENTCARDS_DOCTORS FOREIGN KEY(DOCTOR_ID)
	REFERENCES DOCTORS(ID_DOCTOR),
	CONSTRAINT FK_PATIENTCARDS_USERS FOREIGN KEY(USER_ID)
	REFERENCES USERS(ID_USER))
END;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = 'VERSION')
BEGIN
	CREATE TABLE VERSION(ID INT NOT NULL,
	VERSION_NUM VARCHAR(30) NOT NULL,
	CONSTRAINT PK_VERSION PRIMARY KEY (ID))
END;

IF (SELECT count(*) FROM DOCTORS) = 0
BEGIN
INSERT INTO DOCTORS(ID_DOCTOR, FIRSTNAME, LASTNAME, PHONENUM, CABNUM, SPECIALITY, DOC_PASSWORD)
VALUES(1, 'Taras', 'Banan', 380983925789, 100, 'Dentist', 'BLABLABLA');

INSERT INTO DOCTORS(ID_DOCTOR, FIRSTNAME, LASTNAME, PHONENUM, CABNUM, SPECIALITY, DOC_PASSWORD)
VALUES(2, 'Oleg', 'Kolobok', 380936836523, 101, 'Dentist', 'BYBYBY');

INSERT INTO DOCTORS(ID_DOCTOR, FIRSTNAME, LASTNAME, PHONENUM, CABNUM, SPECIALITY, DOC_PASSWORD)
VALUES(3, 'QUEEN', 'Angry', 380952154876, 102, 'Dentist-surgeon', 'Rock-n-roll');
END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = 'PATIENTCARDS')
BEGIN
	ALTER TABLE PATIENTCARDS
	DROP CONSTRAINT FK_PATIENTCARDS_USERS;
END;


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = 'DOC_RECEPTION')
BEGIN
	ALTER TABLE DOC_RECEPTION
	DROP CONSTRAINT FK_DOC_RECEPTION_USERS
END;

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = 'USER_DOCTOR')
BEGIN
	ALTER TABLE USER_DOCTOR
	DROP CONSTRAINT FK_USER_DOCTOR_USERS
END;

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = 'USERS')
BEGIN
	ALTER TABLE USERS
	DROP CONSTRAINT PK_USERS;
	ALTER TABLE USERS
	DROP COLUMN ID_USER;
	ALTER TABLE USERS
	ADD ID_USER INT IDENTITY(1,1) CONSTRAINT PK_USERS PRIMARY KEY(ID_USER);
END;

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = 'PATIENTCARDS')
BEGIN
	ALTER TABLE PATIENTCARDS    
	ADD CONSTRAINT FK_PATIENTCARDS_USERS FOREIGN KEY (USER_ID)     
    REFERENCES USERS (ID_USER)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE
END;


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = 'DOC_RECEPTION')
BEGIN
	ALTER TABLE DOC_RECEPTION    
	ADD CONSTRAINT FK_DOC_RECEPTION_USERS FOREIGN KEY (USER_ID)     
    REFERENCES USERS (ID_USER)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE;
END;


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = 'USER_DOCTOR')
BEGIN
	ALTER TABLE USER_DOCTOR   
	ADD CONSTRAINT FK_USER_DOCTOR_USERS FOREIGN KEY (USER_ID)     
    REFERENCES USERS (ID_USER)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE;
END;

IF NOT EXISTS (SELECT *
          FROM   INFORMATION_SCHEMA.COLUMNS
          WHERE  TABLE_NAME = 'USERS'
                 AND COLUMN_NAME = 'EMAIL')
BEGIN
	ALTER TABLE USERS
	ADD EMAIL VARCHAR(320) NOT NULL
END;

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = 'USERS')
BEGIN
	ALTER TABLE USERS
	ALTER COLUMN USER_PASSWORD NVARCHAR(MAX) NOT NULL
END;


IF object_id('spAddUser') IS NULL
    EXEC ('create procedure dbo.spAddUser as select 1')
GO
ALTER PROCEDURE spAddUser
@FIRSTNAME VARCHAR(30), @LASTNAME VARCHAR(30), @PHONENUM BIGINT, @USER_PASSWORD VARCHAR(20), @EMAIL VARCHAR(320)
AS
BEGIN
INSERT INTO USERS(FIRSTNAME, LASTNAME, PHONENUM, USER_PASSWORD, EMAIL)
VALUES (@FIRSTNAME, @LASTNAME, @PHONENUM, @USER_PASSWORD, @EMAIL)
END;

GO

IF object_id('spCheckUser') IS NULL
    EXEC ('create procedure dbo.spCheckUser as select 1')
GO
ALTER PROCEDURE dbo.spCheckUser
@PHONENUM BIGINT, @COUNT INT OUTPUT
AS
BEGIN
SELECT @COUNT = count(*) 
FROM USERS 
WHERE PHONENUM = @PHONENUM
END;

GO

IF object_id('spCheckLogin') IS NULL
    EXEC ('create procedure dbo.spCheckLogin as select 1')
GO
ALTER PROCEDURE spCheckLogin
@PHONENUM BIGINT, @USER_PASSWORD NVARCHAR(MAX) OUTPUT
AS
BEGIN
SELECT @USER_PASSWORD = USER_PASSWORD 
FROM USERS 
WHERE PHONENUM = @PHONENUM
END;

GO

IF object_id('spAddUser') IS NULL
    EXEC ('create procedure dbo.spAddUser as select 1')
GO
ALTER PROCEDURE spAddUser
@FIRSTNAME VARCHAR(30), @LASTNAME VARCHAR(30), @PHONENUM BIGINT, @USER_PASSWORD NVARCHAR(MAX), @EMAIL VARCHAR(320)
AS
BEGIN
INSERT INTO USERS(FIRSTNAME, LASTNAME, PHONENUM, USER_PASSWORD, EMAIL)
VALUES (@FIRSTNAME, @LASTNAME, @PHONENUM, @USER_PASSWORD, @EMAIL)
END;

GO


IF object_id('spCheckLogin') IS NULL
    EXEC ('create procedure dbo.spCheckLogin as select 1')
GO
ALTER PROCEDURE spCheckLogin
@PHONENUM BIGINT, @USER_PASSWORD NVARCHAR(MAX) OUTPUT , @ID_USER INT OUTPUT
AS
BEGIN
SELECT @USER_PASSWORD = USER_PASSWORD , @ID_USER=ID_USER
FROM USERS 
WHERE PHONENUM = @PHONENUM
END;
