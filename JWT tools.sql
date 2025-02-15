-----------------------------------------------------------------
-- Helper function
-- drop function if exists svc._base64url_json
create or replace function svc._base64url_json(t text) 
returns json language sql immutable as $function$
  select convert_from(decode(rpad(
			translate(t, '-_', '+/'), 
			4 * ((length(t) + 3) / 4), 
			'='), 
		'base64'), 
	'utf-8')::json;
$function$;
-----------------------------------------------------------------
-- drop function if exists svc.jwt_payload
create or replace function svc.jwt_payload(arg_jwt text)
returns json language sql immutable as $function$
  select svc._base64url_json(split_part(arg_jwt, '.', 2));
$function$;
-----------------------------------------------------------------
-- drop function if exists svc.verify_jwt
create or replace function svc.verify_jwt(arg_jwt text, arg_secret text)
returns boolean immutable language sql as $function$
with parts(arr) as 
(
  select string_to_array(trim(arg_jwt), '.')
)
select translate(encode(hmac(arr[1]||'.'||arr[2], 
	arg_secret, 
	case svc._base64url_json(arr[1])->>'alg' 
		when 'HS256' then 'sha256'
		when 'HS384' then 'sha384'
		when 'HS512' then 'sha512'
	end), 'base64'), '+/=', '-_') = arr[3]
from parts;
$function$;
-----------------------------------------------------------------
-- Unit test
with t(jwt) as (
 select 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzM4NCJ9.eyJpc3MiOiJCYWogU3RlZmFuIiwiaWF0IjoxNzM5NTU5OTc1LCJleHAiOjE3NzExMDEzNDcsImF1ZCI6IiIsInN1YiI6IiIsIkdpdmVuTmFtZSI6IkJhaiIsIlN1cm5hbWUiOiJTdGVmYW4ifQ.cYkdM4J42_d61Bz5ecgxu_mcp-baeoAitgNr7VmtWddgkMXeO_Wn1E_sQYEyyJv9'
)
select svc.jwt_payload(jwt), svc.verify_jwt(jwt, 'Baba123Meca')
from t;
