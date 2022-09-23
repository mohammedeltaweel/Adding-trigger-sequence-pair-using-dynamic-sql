SET SERVEROUTPUT ON
DECLARE
        CURSOR add_seq_cursor IS
            SELECT cols.table_name, cols.column_name, cols.position, cons.status, cons.owner
            FROM all_constraints cons, all_cons_columns cols
            WHERE cons.constraint_type = 'P'  and cols.owner = 'HR'
            AND cons.constraint_name = cols.constraint_name
            AND cons.owner = cols.owner
            AND position=1;
            
v_count number(4);
BEGIN
    FOR rec IN add_seq_cursor LOOP
    
    --CHECK IF THE SEQUENCE ALREADY EXISTS
    SELECT COUNT(*) into v_count
    FROM all_sequences
    WHERE sequence_owner = 'HR' AND sequence_name = rec.table_name || '_' || rec.position || '_SEQ';
      IF (v_count = 0) THEN
    
    --CREATING THE SEQUENCE WITH NAME OF TABLE_NAME_POSITION_SEQ
    EXECUTE IMMEDIATE 'CREATE SEQUENCE ' || rec.table_name || '_' || rec.position ||'_SEQ 
            START WITH 100 
            INCREMENT BY 5 
            MAXVALUE 9999999999 
            MINVALUE 1 
            NOCYCLE CACHE 20 
            NOORDER' ;
    END IF;
    
     EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER HR.'|| rec.table_name || '_trg' ||
' BEFORE INSERT
ON HR.' || rec.table_name || ' REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
BEGIN
    :new.' || rec.column_name || ' :=  ' ||rec.table_name || '_' || rec.position ||'_SEQ.nextval;
END;'  ;


    END LOOP;

END;
