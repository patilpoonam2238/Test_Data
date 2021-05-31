SET SERVEROUTPUT ON;
DECLARE
  req        utl_http.req;
  resp       utl_http.resp;
  v_content  blob;
  amount     number := 2000;
  req_length NUMBER;
  v_offset   NUMBER := 1;
  v_buffer   varchar2(4000);
  l_response_header_name varchar2(256);
  l_response_header_value varchar2(1024);
  l_request_body clob;
  l_response_body varchar2(32767);

CURSOR cur_updated_data IS
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
AND TO_DATE(vhr.creation_date) =TO_DATE(SYSDATE) OR 
AND   hca.status ='A'
AND chr.sts_code ='BOOKED';  
BEGIN


/*utl_http.set_wallet(
    path => 'file:/xxx/apps/xxx/xxx/19.0.0/wallet',
    password => 'password'
  );*/

  utl_http.set_proxy ('proxy.deere.com:8080');

  req := utl_http.begin_request(
                      url => 'https://t1pmb7o2b4.execute-api.ap-south-1.amazonaws.com/devl/contracts?',
                      method => 'POST',
                      http_version => 'HTTP/1.1'
                    );

 -- utl_http.set_header(req, 'user-agent',    'mozilla/4.0');
 utl_http.set_header(req, 'Authorization', 'Bearer eyJraWQiOiJDR0RJQ0VjU1BoVXpmcGpGUEl0YXZ3SEt1M1FodVVXY1JBZTR4dFFjcTcwIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULjNSN0VGWGppUUJSXzNmRHVUNzh4elJfVkVSOHlNZDFjaEVTSFQ4T1ZWTVUiLCJpc3MiOiJodHRwczovL3Nzby1kZXYuam9obmRlZXJlLmNvbS9vYXV0aDIvYXVzZ25oMXd6OVlQaVVYRFcwaDciLCJhdWQiOiJqZGYtZGV2IiwiaWF0IjoxNjE2NTg1MDgzLCJleHAiOjE2MTY1ODg2ODMsImNpZCI6IjBvYXVsd2ZsY2RsdlZVNHo5MGg3Iiwic2NwIjpbImpkZi1kZXYiXSwic3ViIjoiMG9hdWx3ZmxjZGx2VlU0ejkwaDcifQ.VcL2cvkXEdQDLb6khVwvwOXfnT4HvwOqrsO5bNhQRJrKaBOYdKP5injw7cY9ro5mZd5Fyi_CHSa2b9Li6YT1VEQZ5HQfwm5kA2icZQ9W2fYypseHxD84jrPndIUEvYsAq9TL9UHp84N3UpBHxgzxg_nxKK2wgzqCfihQLlWcw_yHVQDmeah1oNZXr2BM7zQJCHK6KeafE8DBtC5EgssNzi4WYd0a6tnwofncumGTiSvWwplwMyGvO3rg6Gpx1hajKJyxjLhxHO0tKO5sasJ3kXFxfK557XFhfwAtHpH4GJp4j63isJP5yPHVgbOc5GxSX1sqquPnuzZ19IkGtilk4g');
  utl_http.set_header(req, 'content-type', 'application/json'); 
  utl_http.set_header(req, 'Content-Length', length(v_content));
 
  req_length := dbms_lob.getlength(v_content);

  if req_length <= 32767   then 
    utl_http.set_header(req, 'Content-Length', req_length);
    utl_http.write_raw(req, v_content);
  elsif req_length > 32767 THEN

    utl_http.set_header(req, 'Transfer-Encoding', 'Chunked');

    while (v_offset < req_length) LOOP
      dbms_lob.read(v_content, amount, v_offset, v_buffer);
      utl_http.write_raw(req, v_buffer);
      v_offset := v_offset + amount;
    end loop;
  end if;

  resp := UTL_HTTP.get_response(req);
  
  for i in 1 .. utl_http.get_header_count(resp) loop
    utl_http.get_header(resp, i, l_response_header_name, l_response_header_value);
    dbms_output.put_line('Response Header> ' || l_response_header_name || ': ' || l_response_header_value);
  end loop;
  
  utl_http.read_text(resp, l_response_body, 32767);
  dbms_output.put_line('Response body>');
  dbms_output.put_line(l_response_body);

  -- Process the response from the HTTP call
    IF resp.status_code = utl_http.HTTP_OK AND resp.reason_phrase = 'OK' THEN
      dbms_output.put_line ('Webservice without errors');
    ELSE
      dbms_output.put_line ('Webservice errors=' || resp.status_code || '-' || resp.reason_phrase);
    END IF;
    utl_http.end_response (resp);

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line ('ERROR Others=' || SQLERRM);
    utl_http.end_response (resp);
END;