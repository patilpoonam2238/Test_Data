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
AND chr.contract_number = '84104';	