/*
Script Name: create_obms_system_user.sql
Author: @Ayon-SSP
Date Created: 2024-03-06
Purpose: Script to create the 'obms_system' user and grant necessary privileges.
*/

-- Set _ORACLE_SCRIPT for pluggable databases -- not specifically working with a PDB
alter session set "_ORACLE_SCRIPT"=true; 

-- Create the 'obms_system' user
CREATE USER obms_system IDENTIFIED BY 321654;

------------------------------------------------------
-- Grant necessary privileges to the 'obms_system' user
------------------------------------------------------
GRANT CREATE SESSION TO obms_system;          -- Allow user to connect to the database
GRANT CREATE TABLE TO obms_system;            -- Allow user to create tables
GRANT CREATE VIEW TO obms_system;             -- Allow user to create views
GRANT CREATE ANY TRIGGER TO obms_system;      -- Allow user to create triggers
GRANT CREATE ANY PROCEDURE TO obms_system;    -- Allow user to create procedures
GRANT CREATE SYNONYM TO obms_system;          -- Allow user to create synonyms
GRANT ALL PRIVILEGES TO obms_system;          -- Grant all privileges (be cautious with this)
GRANT CONNECT TO obms_system;                 -- Grant connect privilege
GRANT RESOURCE TO obms_system;                -- Grant resource privilege

-- Grant all privileges to obms_system
GRANT ALL PRIVILEGES TO obms_system;
GRANT DBA TO obms_system;                   -- system-level privileges
-- GRANT SELECT, INSERT, UPDATE, DELETE ON exampleTable TO obms_system; -- object-level privileges

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

-- Drop the 'obms_system' user if needed
-- DROP USER obms_system;