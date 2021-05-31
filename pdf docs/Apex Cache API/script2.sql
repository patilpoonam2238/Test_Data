SET SERVEROUTPUT ON;

BEGIN

DBMS_OUTPUT.PUT_line('Calling API');
publish_contract_event(627879);--,null,null);

EXCEPTION
WHEN OTHERS THEN
 dbms_output.put_line('error'||SQLERRM);
END;

/
create or replace
procedure publish_contract_event
( customerId in varchar2
--, P_CUST_ACCT_ID in number
--,P_CUST_ACCT_NUMBER VARCHAR2
) is
  req utl_http.req;
  res utl_http.resp;
  url varchar2(4000) := 'https://t1pmb7o2b4.execute-api.ap-south-1.amazonaws.com/devl/contracts?';
  name varchar2(4000);
  buffer varchar2(4000); 
  content varchar2(4000) := '{"customerId":"'||customerId||'"}';--, "P_CUST_ACCT_ID":"'||P_CUST_ACCT_ID||'","P_CUST_ACCT_NUMBER":"'||P_CUST_ACCT_NUMBER||'"}';
 
begin
  req := utl_http.begin_request(url, 'GET',' HTTP/1.1');
  --utl_http.set_header(req, 'user-agent', 'mozilla/4.0'); 
--  UTL_HTTP.SET_AUTHENTICATION(req, 'ASADMIN', 'jdfintd5');
  utl_http.set_header(req, 'content-type', 'application/json'); 
  utl_http.set_header(req, 'Content-Length', length(content));
 
  utl_http.write_text(req, content);
  res := utl_http.get_response(req);
  -- process the response from the HTTP call
  begin
    loop
      utl_http.read_line(res, buffer);
      dbms_output.put_line(buffer);
    end loop;
    utl_http.end_response(res);
  exception
    when utl_http.end_of_body 
    then
      utl_http.end_response(res);
  end;
end publish_contract_event;