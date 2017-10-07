#Oracle 2 SQL Server
===================
@author Stefan Jud (SoulTransfer)
@created 07.10.2017

@param DATABASE  Name of the Oracle database 
@param APPL_PASS Password of the Oracle database
@param SCHEMNA Schema which should be copied
@param TO_DB SQL Server Database to copy too
@param TO_SCHEMNA Sql Server Schema the new tables will be created in


Generate automatically SQL Server Tables CREATE Scripts from an Oracle Schema.
The Script should be run from SQL*Plus*, the command line tool for ORACLE RDBMS. The 
Script file is automatically created during the script run.

This script is for AL32UTF8 Databases. (The used VARCHAR2 corresponding 
string datatype is nvarchar which is the explicit UTF8 datatype of SQL Server). But
it should work with WE1252WIN databases too.

#Example
You can run the script with the following command:
sqlplus /nolog @Oracle


