select * from oks_stream_levels_b;

  SELECT sel.*
    FROM   okl_strm_elements sel,
           okl_streams stm,
           okl_strm_type_b sty
    WHERE  stm.say_code = 'CURR'
    AND    stm.active_yn = 'Y'
    AND    stm.purpose_code is NULL
    AND    stm.khr_id = 8485995
    AND    sty.id = stm.sty_id
    AND    sty.billable_yn = 'Y'
    AND    sel.stm_id = stm.id;
    AND    date_billed is null;
--    AND    stream_element_date <= c_date
    AND    sty.stream_type_purpose in ('RENT','DOWN_PAYMENT');
    
    
    
    SELECT  chrb.id
              ,chrb.contract_number
              ,pdtv.name            product_name
              ,chrb.cust_acct_id
              ,hzp.party_name        customer_name
              ,cbidv.ar_invoice_id   invoice_id
              ,cbidv.invoice_number  invoice_number
              ,sum(cbidv.amount_remaining) amount_remaining
              ,cbidv.due_date
              ,chrb.currency_code
      FROM    okl_cs_bpd_inv_dtl_v  cbidv,
              ra_customer_trx       ratrx,
              ra_cust_trx_types     rattyp,
              okc_k_headers_b       chrb,
              okl_k_headers         khr,
              okl_products_v        pdtv,
              hz_cust_accounts      hza,
              hz_parties            hzp
      WHERE   cbidv.ar_invoice_id     =  ratrx.customer_trx_id
      AND     ratrx.cust_trx_type_id  =  rattyp.cust_trx_type_id
      AND     rattyp.type             = 'INV'
      AND     cbidv.customer_acct_id  = chrb.cust_acct_id
      AND     cbidv.chr_id            = 8485995--chrb.id
      AND     cbidv.amount_remaining  > 0
      AND     cbidv.due_date          <= sysdate
      AND     chrb.cust_acct_id       =  cbidv.customer_acct_id
      AND     khr.id                  =  chrb.id
      --AND     pdtv.id                 = NVL(cp_financial_product,pdtv.id)
      AND     hza.cust_account_id     = chrb.cust_acct_id
      AND     hzp.party_id            = hza.party_id
      AND     khr.pdt_id              = pdtv.id
      AND     chrb.sts_code           in ('BOOKED','TERMINATED','EVERGREEN')
      Group By chrb.id
              ,chrb.contract_number
              ,pdtv.name
              ,chrb.cust_acct_id
              ,hzp.party_name
              ,cbidv.ar_invoice_id
              ,cbidv.invoice_number
              ,cbidv.due_date
              ,chrb.currency_code
      order by chrb.contract_number, cbidv.invoice_number;
	  
	  
	   SELECT sty.code,sel.amount
    FROM   okl_strm_elements sel,
           okl_streams stm,
           okl_strm_type_b sty
    WHERE  stm.say_code = 'CURR'
    AND    stm.active_yn = 'Y'
    --AND    stm.purpose_code is NULL
    AND    stm.khr_id = 10719066
    AND    sty.id = stm.sty_id
    AND    sty.billable_yn = 'Y'
    AND    sel.stm_id = stm.id;
    AND    date_billed is null;
--    AND    stream_element_date <= c_date
    AND    sty.stream_type_purpose in ('RENT','DOWN_PAYMENT');
    
    
	
	BEGIN
mo_global.set_policy_context('S',142);
END;
/

select * from oks_stream_levels_b;

select * from hr_operating_units; --142

select * from okc_k_headers_all_b  where contract_number like '46838';--
order by creation_date desc;

select * from okc_k_lines_b where chr_id=7024995;
select * from lns_loan_headers_all;

select * from OKL_CS_BPD_INV_DTL_V where chr_id=7024995;

select * from OKL_TRX_HEADER_UV where contract_number ='46838';--'115780';

select * from ra_customer_trx_all where customer_trx_id=9859453;

select * from oks_bill_transactions;


SELECT distinct hca.account_number Cust_Identification_ID,hp.party_type
 ,chr.sts_code,Initcap(hp.party_name)
 ,initcap(hp.person_first_name ||' '||hp.person_middle_name ) first_name
 ,initcap(hp.person_last_name)
 ,hcp.phone_number,hcp.primary_flag,hcp.phone_line_type--,count(hps.party_site_id)
    FROM okc_k_headers_all_b chr
	    ,hz_cust_accounts_all hca
		,hz_cust_acct_sites_all hcasa
		,hz_party_sites hps
		,HZ_CUST_SITE_USES_ALL HCSUA
        ,hz_parties hp
		,hr_operating_units hou
        ,XXJDF_CONTRACT_NACH nach
        ,hz_contact_points hcp
 WHERE   chr.cust_acct_id = hca.cust_account_id
        AND (chr.contract_number) = to_char(trunc(nach.contract_number))
       -- AND trunc(nach.contract_number) ='146009'
         AND hcasa.party_site_id = hps.party_site_id
         AND hp.party_id =hps.party_id 
         AND hcasa.cust_acct_site_id=hcsua.cust_acct_site_id
         AND hca.party_id=hp.party_id
         AND hca.cust_account_id =hcasa.cust_account_id
		 AND hou.organization_id =chr.org_id
		 AND hou.organization_id =hcasa.org_id
         ANd hcp.OWNER_TABLE_ID(+) =hps.party_site_id
 AND     hcp.contact_point_type(+) IN ( 'PHONE')
-- AND hcp.phone_line_type ='MOBILE'
 ANd chr.sts_code ='BOOKED'
ANd hca.account_number in('126122')
 --AND      hcp.status ='A'
 ANd hcp.primary_flag ='Y'
 AND hp.party_type <> 'ORGANIZATION'
         AND hcsua.status  = 'A'
         AND hca.status    = 'A'	
		 AND  hp.status    = 'A'
		 AND hcasa.status  = 'A';	
		 
		 
		 
		 SELECT distinct
 chr.contract_number,chr.id
,chr.start_date loan_start_date
 ,chr.end_date loan_end_date
 ,khr_history.start_date old_loan_start_date
 ,khr_history.end_date  old_loan_end_date
 ,(SELECT distinct okl_lla_util_pvt.get_lookup_meaning('OKL_FREQUENCY',rul.object1_id1) frequency
--,rul.
      FROM okc_rules_b rul,
        okc_rule_groups_b rgp,
        okc_rules_b rul_laslh,
        okl_strm_type_b styt
      WHERE rul.rgp_id                        = rgp.id
      AND rgp.rgd_code                        = 'LALEVL'
      AND rul.rule_information_category       = 'LASLL'
      AND rgp.dnz_chr_id                      = chr.id
      AND rul.jtot_object2_code               = 'OKL_STRMHDR'
      AND rul.dnz_chr_id                      = rgp.dnz_chr_id
      AND rul_laslh.rgp_id                    = rgp.id
      AND rul_laslh.dnz_chr_id                = rgp.dnz_chr_id
      AND rul_laslh.rule_information_category = 'LASLH'
      AND rul_laslh.jtot_object1_code         = 'OKL_STRMTYP'
	  AND rul.object2_id1               	  = rul_laslh.id
      AND styt.id                             = rul_laslh.object1_id1
      AND styt.code                           = 'RENT') new_payment_frequency
, (SELECT distinct okl_lla_util_pvt.get_lookup_meaning('OKL_FREQUENCY',rul.object1_id1) frequency
--,rul.
      FROM okc_rules_bh rul,
        okc_rule_groups_b rgp,
        okc_rules_bh rul_laslh,
        okl_strm_type_b styt
      WHERE rul.rgp_id                        = rgp.id
      AND rgp.rgd_code                        = 'LALEVL'
      AND rul.rule_information_category       = 'LASLL'
      AND rgp.dnz_chr_id                      = chr.id
      AND rul.jtot_object2_code               = 'OKL_STRMHDR'
      AND rul.dnz_chr_id                      = rgp.dnz_chr_id
      AND rul_laslh.rgp_id                    = rgp.id
      AND rul_laslh.dnz_chr_id                = rgp.dnz_chr_id
      AND rul_laslh.rule_information_category = 'LASLH'
      AND rul_laslh.jtot_object1_code         = 'OKL_STRMTYP'
	  AND rul.object2_id1               	  = rul_laslh.id
      AND styt.id                             = rul_laslh.object1_id1
      AND styt.code                           = 'RENT') old_payment_frequency
FROM okc_k_headers_all_b chr
	,hz_cust_accounts_all hca
    ,okc_k_headers_all_bh khr_history
WHERE chr.id =khr_history.id(+)
AND chr.cust_acct_id =hca.cust_account_id
AND   hca.status ='A'
AND chr.sts_code ='BOOKED'
AND chr.contract_number = '84104';rogram