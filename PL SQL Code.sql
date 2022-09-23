SET SERVEROUTPUT ON
DECLARE
        CURSOR add_seq_cursor IS
            SELECT DISTINCT cls.table_name, cls.column_name, cls.position, cns.status, cns.owner,  tbl_cls.data_type
            FROM all_constraints cns, all_cons_columns cls, user_tab_columns tbl_cls
            WHERE cns.constraint_type = 'P'  and cls.owner = 'HR'
            AND cns.table_name = tbl_cls.table_name
            AND cns.constraint_name = cls.constraint_name
            AND cns.owner = cls.owner
            AND position=1
            AND tbl_cls.data_type = 'NUMBER'
            AND NULLABLE = 'N';
            
 
v_count number(4);
BEGIN
    FOR rec IN add_seq_cursor LOOP
    
    --CHECK IF THE SEQUENCE ALREADY EXISTS
    SELECT COUNT(*) into v_count
    FROM all_sequences
    WHERE sequence_owner = 'HR' AND sequence_name = rec.table_name  || '_SEQ';
      IF (v_count = 0) THEN
    
    --CREATING THE SEQUENCE WITH NAME OF TABLE_NAME_POSITION_SEQ 
    EXECUTE IMMEDIATE 'CREATE SEQUENCE ' || rec.table_name || '_SEQ 
            START WITH 100000 
            INCREMENT BY 5 
            MAXVALUE 9999999999 
            MINVALUE 1 
            NOCYCLE CACHE 20 
            NOORDER' ;
    END IF;
    
    EXECUTE IMMEDIATE  'CREATE OR REPLACE TRIGGER HR.'|| rec.table_name || '_TRG' ||
' BEFORE INSERT
ON HR.' || rec.table_name || ' REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
BEGIN
    :new.' || rec.column_name || ' :=  ' ||rec.table_name ||'_SEQ.nextval;
END;' ;
    END LOOP;

END;
