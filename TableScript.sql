PROMPT '------------------------------------------------------------'
PROMPT '                                                            '
PROMPT '   Data Migration Table Generator                           '
PROMPT '                                                            '
PROMPT '------------------------------------------------------------'

ACCEPT DATABASE  prompt 'Datenbank:                  '
ACCEPT APPL_PASS prompt 'Password for schema user:   ' HIDE
ACCEPT SCHEMNA prompt 'Schema to Copy:           '
ACCEPT TO_DB prompt 'Sql Server Database:      '
ACCEPT TO_SCHEMNA prompt 'Sql Server Schema:      '

set heading off
SET verify   OFF
SET echo     OFF
SET feedback OFF
set serveroutput on
set serveroutput on size unlimited

CONNECT &&SCHEMNA/&&APPL_PASS@&&DATABASE

UNDEFINE SPOOLFILENAME
COLUMN filename NEW_VALUE SPOOLFILENAME
SELECT 'import_tables.sql' filename 
FROM dual;

-- spool-file anfangen
spool &&SPOOLFILENAME REPLACE
set heading off

SPOOL OFF

CONNECT &&SCHEMNA/&&APPL_PASS@&&DATABASE
set serveroutput on size unlimited
spool &&SPOOLFILENAME APPEND

DECLARE
PROCEDURE generate_table_script(schema_name_p VARCHAR2)
IS
CURSOR table_c IS
SELECT t.table_name table_data
FROM user_tables t;
CURSOR rows_c(table_p VARCHAR2) IS
SELECT CASE
           WHEN s.data_type = 'NUMBER' AND s.data_scale >=1
               THEN s.column_name || ' [decimal](' || s.data_precision || ', ' || s.data_scale || ')'
           WHEN s.data_type = 'NUMBER'
               THEN s.column_name || ' [decimal](' || NVL2(s.data_precision,s.data_precision,'20') || ')'
           WHEN s.data_type = 'BOOLEAN'
               THEN s.column_name || ' [bit]'
           WHEN s.data_type = 'timestamp'
               THEN s.column_name || ' [datetime2]'
           WHEN s.data_type = 'VARCHAR2' OR s.data_type = 'CHAR' OR s.data_type = 'STRING' OR s.data_type = 'NVARCHAR2' OR s.data_type = 'NCHAR'
               THEN s.column_name ||  ' [nvarchar](' || s.char_length || ')'
           WHEN s.data_type = 'DATE' 
               THEN s.column_name || ' [datetime2](7)'
           WHEN s.data_type = 'CLOB' 
               THEN s.column_name || ' [varchar](max)'
           WHEN s.data_type = 'BLOB' OR s.data_type = 'RAW' OR s.data_type = 'LONG RAW' OR  s.data_type = 'BFILE'
               THEN s.column_name || ' [varbinary](max)'
           WHEN s.data_type = 'XMLTYPE' 
               THEN s.column_name || ' [xml]'
           WHEN s.data_type = 'PLS_INTEGER' OR s.data_type = 'INT'  OR s.data_type = 'INTEGER' 
               THEN s.column_name || ' [int]'
       END ||
       CASE
           WHEN s.nullable = 'Y'
               THEN ' NULL,' ||CHR(10)
           ELSE
              ' NOT NULL,' ||CHR(10)
       END column_data
FROM user_tab_columns s
WHERE s.table_name = table_p
order by s.column_id;
script_v CLOB;
schema_v VARCHAR2(100);
schema_v2 STRING(100);
BEGIN
schema_v := schema_name_p;
dbms_output.put_line('USE &&TO_DB' ||CHR(10)||'GO'||CHR(10));
FOR table_v IN table_c LOOP
   script_v := 'CREATE TABLE ['||schema_v||'].' || table_v.table_data || '(' ||CHR(10);
   FOR rows_v IN rows_c(table_v.table_data) LOOP
       script_v := script_v||rows_v.column_data;
   END LOOP;
   script_v := SUBSTR(script_v,1,LENGTH(script_v)-2) || ');' ||CHR(10)|| 'GO' ||CHR(10);
   dbms_output.put_line(script_v); 
END LOOP;
END generate_table_script;
BEGIN
generate_table_script('&&TO_SCHEMNA');
END;
/

SPOOL OFF

EXIT
