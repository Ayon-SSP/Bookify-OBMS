/*
Script Name: create_obms_admin_user.sql
Author: @Ayon-SSP
Date Created: 2024-03-06
Purpose: Script to create the 'obms_admin' user and grant necessary privileges.
*/

-- Set _ORACLE_SCRIPT for pluggable databases -- not specifically working with a PDB
alter session set "_ORACLE_SCRIPT"=true; 

-- Create the 'obms_admin' user
CREATE USER obms_admin IDENTIFIED BY 321654;

------------------------------------------------------
-- Grant necessary privileges to the 'obms_admin' user
------------------------------------------------------
GRANT CREATE SESSION TO obms_admin;          -- Allow user to connect to the database
GRANT CREATE TABLE TO obms_admin;            -- Allow user to create tables
GRANT CREATE VIEW TO obms_admin;             -- Allow user to create views
GRANT CREATE ANY TRIGGER TO obms_admin;      -- Allow user to create triggers
GRANT CREATE ANY PROCEDURE TO obms_admin;    -- Allow user to create procedures
GRANT CREATE SYNONYM TO obms_admin;          -- Allow user to create synonyms
GRANT ALL PRIVILEGES TO obms_admin;          -- Grant all privileges (be cautious with this)
GRANT CONNECT TO obms_admin;                 -- Grant connect privilege
GRANT RESOURCE TO obms_admin;                -- Grant resource privilege

-- Grant all privileges to obms_admin
GRANT ALL PRIVILEGES TO obms_admin;
GRANT DBA TO obms_admin;                   -- system-level privileges
-- GRANT SELECT, INSERT, UPDATE, DELETE ON exampleTable TO obms_admin; -- object-level privileges

-- Display list of users
SELECT 
		username, 
		default_tablespace, 
		profile, 
		authentication_type
	FROM
		dba_users 
	WHERE 
		account_status = 'OPEN'
	ORDER BY
		username; 

-- Drop the 'obms_admin' user if needed
-- DROP USER obms_admin;