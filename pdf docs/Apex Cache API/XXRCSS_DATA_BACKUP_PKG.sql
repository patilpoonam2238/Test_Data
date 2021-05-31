create or replace PACKAGE XXRCSS_DATA_BACKUP_PKG AS 

function main_contract_data_bkp RETURN BOOLEAN;

PROCEDURE call_process_api();

END XXRCSS_DATA_BACKUP_PKG;
/

create or replace PACKAGE BODY XXRCSS_DATA_BACKUP_PKG AS 

function main_contract_data_bkp RETURN BOOLEAN IS
 l_contract_num okc_k_headers_all_b.contract_number%TYPE;
BEGIN  
	 select distinct chr.contract_number
     -- ,chr.start_date new_start_date
     -- ,chr.end_date new_end_date
 INTO l_contract_num
      from okc_k_headers_all_bh history
            ,okc_k_headers_all_b chr
      where history.id =chr.id
      AND  ( history.end_date <> chr.end_date  
      OR   history.start_date <> chr.start_date )
      AND chr.authoring_org_id ='142'
      AND chr.sts_code ='BOOKED'
      AND to_date(chr.last_update_date,'DD-MON-YYYY') = TO_DATE(SYSDATE,'DD-MON-YYYY')-30;
EXCEPTION	

END;
  
PROCEDURE call_process_api IS

BEGIN
null;
END;	  


END XXRCSS_DATA_BACKUP_PKG;
/