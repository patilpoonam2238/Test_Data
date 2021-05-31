
Body parameters:

KEY VALUE
file (required) 111.pdf file to send


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
  
BEGIN

  -- The image file
  SELECT hd.hdk_anexo_1
  INTO   v_content
  FROM   table hd
  WHERE  hd.hdk_id = 999;

utl_http.set_wallet(
    path => 'file:/xxx/apps/xxx/xxx/19.0.0/wallet',
    password => 'password'
  );

  utl_http.set_proxy ('proxy.xxx.xxx:8080');

  req := utl_http.begin_request(
                      url => 'https://cloudcc.nos.pt/upload/upload2tickets.php',
                      method => 'POST',
                      http_version => 'HTTP/1.1'
                    );

  utl_http.set_header(req, 'user-agent',    'mozilla/4.0');
  utl_http.set_header(req, 'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJpZmFwLmNsb3VkY2Mubm9zLnB0IiwiaXNzVXVpZCI6IjdlNGU1OGQwLWM3NDAtNDA2Ni05YzY1LWY3NmQzY2Y2MDE0OSIsImp0aSI6IjQwZDViZjMwLWYwNDktNDM3Yy1iYTFhLTk4MmUxODFiYmQ5ZCIsIm5hbWUiOiJ1c2VyX2FwaSIsInBlcm0iOltdLCJyYW5nZUxpc3QiOltdLCJpYXQiOjE1ODU1Nzc1MzYsImV4cCI6MTU4NjE4MjMzNn0.fHWRbxOUtTx-zb-14AeCBaL-8U5BbpinuW7tYtqzh');
  utl_http.set_header(req, 'content-type',  'image/jpeg');

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