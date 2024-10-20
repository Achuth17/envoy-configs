-- Called on the request path.
function envoy_on_request(request_handle)
  local auth_key = "X-API-KEY"
  local api_key_value = nil
  local path = request_handle:headers():get(":path")
  local api_key_param_value = extract_query_param_from_path(path, auth_key)
  -- First, Try to extract the API-KEY value from the query param.
  if api_key_param_value ~= nil then
    api_key_value = api_key_param_value
  -- Next, check the headers.
  elseif request_handle:headers():get(auth_key) ~= nil then      
    local headers = request_handle:headers()
    api_key_value = headers:get(auth_key)
  -- If no API-KEY is present in headers or query params, reject the request.
  else
    request_handle:respond({[":status"] = "403"}, "403 - API Key is Invalid!\n")
  end
  -- Make an HTTP call to an auth host to check the validity of the API-KEY.
  local resp_headers, body = request_handle:httpCall(
    "auth_cluster",
    {
    [":method"] = "POST",
    [":path"] = "/auth",
    [":authority"] = "auth_cluster",
    ["X-API-KEY"] = api_key_value
    },
    "",
    5000)
  status_code = resp_headers[":status"]
  request_handle:logInfo(status_code)
  if resp_headers[status_header] ~= "200" then
    -- Respond back as denied, we can short circuit any further filters.
    request_handle:respond({[":status"] = status_code}, body)
  end
end

-- Called on the response path.
function envoy_on_response(response_handle)
end

function extract_query_param_from_path(path, param_name)
  start_index = string.find(path, "?")
  if start_index == nil then
    return
  end
  q_param_string = string.sub(path, start_index+1)
  q_param_pairs = split(q_param_string, "&")
  for i,param_pair in pairs(q_param_pairs) do
    param_split = split(param_pair, "=")
    if (param_split[1] == param_name) then
      return param_split[2]
    end
  end
end

-- Source: https://stackoverflow.com/questions/1426954/split-string-in-lua
function split(s, separator)
  local fields = {}
  
  local insert_func = function (val)
    table.insert(fields, val)
  end

  local pattern = string.format("([^%s]+)", separator)
  string.gsub(s, pattern, insert_func)

  return fields
end
