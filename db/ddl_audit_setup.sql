-- Disable the trigger before making any changes to it
ALTER TRIGGER trg_audit_ddl DISABLE;

-- Drop the trigger to remove it completely
DROP TRIGGER trg_audit_ddl;

-- Drop the table to remove the audit log completely
DROP TABLE obms_schema_audit;

-- Create table obms_schema_audit to store audit information
CREATE TABLE obms_schema_audit (
    audit_date TIMESTAMP,               -- Timestamp of the audit event
    username VARCHAR2(100),            -- User who initiated the DDL operation
    object_type VARCHAR2(100),         -- Type of object affected by the DDL operation (e.g., TABLE, INDEX, VIEW)
    object_name VARCHAR2(100),         -- Name of the object affected by the DDL operation
    ddl_event VARCHAR2(100),           -- Type of DDL event (e.g., CREATE, ALTER, DROP)
    query_text CLOB                    -- Query text associated with the DDL operation
);

-- Create or replace trigger trg_audit_ddl to capture DDL events on the schema
CREATE OR REPLACE TRIGGER trg_audit_ddl
AFTER DDL ON SCHEMA
BEGIN
    -- Insert audit information into the obms_schema_audit table
    INSERT INTO obms_schema_audit VALUES (
        SYSTIMESTAMP,                                          -- Timestamp of the audit event
        sys_context('USERENV', 'CURRENT_USER'),               -- User who initiated the DDL operation
        ora_dict_obj_type,                                     -- Type of object affected by the DDL operation
        ora_dict_obj_name,                                     -- Name of the object affected by the DDL operation
        ora_sysevent,                                          -- Type of DDL event
        SYS_CONTEXT('USERENV', 'CURRENT_SQL')                  -- Capture the current SQL statement
    );
END;
/

-- View the contents of the obms_schema_audit table to see the audit log
SELECT * FROM obms_schema_audit;
