-- drop function if exists svc.randstr;
create or replace function svc.randstr(len integer)
returns text language sql as $function$
  select lpad(substr(random()::text, 3, len), len, '0');
$function$;

-- drop function if exists svc.service_template;
create or replace function svc.service_template(security_info text, request_method text, request_body text, request_vars text)
returns json language plpgsql as $function$
declare
    rq_body json;
    rq_vars json;
    retval  json := '{}';
    HTTP_STATUS_OK constant integer = 200;
    HTTP_STATUS_ERR constant integer = 404;
begin
	-- Verify security_info and bang (HTTP_STATUS_ERR) if not successful
    --------------------------------------------------------------------

    rq_body := cast(request_body as json);
    rq_vars := cast(request_vars as json);

    case request_method
        when 'POST' then 
        -- Your POST implementation here
            retval['status'] := HTTP_STATUS_OK;
            retval['value'] := json_build_object('message', 'Good POST call', 'payload', 123, 'rq', rq_body);
        --------------------------------
        when 'PUT' then 
        -- Your PUT implementation here
            retval['status'] := HTTP_STATUS_OK;
            retval['value'] := json_build_object('message', 'Good PUT call', 'payload', 234, 'rq', rq_body);
        -------------------------------
        when 'GET' then 
        -- Your GET implementation here
            retval['status'] := HTTP_STATUS_OK;
            retval['value'] := json_build_object('message', 'Good GET call', 'payload', 345, 'rq', rq_vars);
        -------------------------------
        else
        -- Other request methods, not implemented
            retval['status'] := HTTP_STATUS_ERR;
            retval['value'] := json_build_object('message', request_method || ' calls not supported');
        -----------------------------------------
    end case;
    return retval;
exception when others then
    -- Log properly your error details here but only return a concise message
        retval['status'] := HTTP_STATUS_ERR;
        retval['value'] := jsonb_build_object(
			'error', randstr(11) -- the error log id here, not a random string
		);
        return retval;
end; $function$;

