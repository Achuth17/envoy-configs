-- Called on the request path.
function envoy_on_request(request_handle)
    local headers = request_handle:headers()
    header_value_to_replace = "User-Agent"
    header_value = headers:get(header_value_to_replace)
    if header_value ~= nil then
      request_handle:logInfo("Replacing UserAgent header found in the request with 'Envoy'")
      request_handle:headers():remove(header_value_to_replace)
      request_handle:headers():add(header_value_to_replace, "Envoy")
    end
  end

  -- Called on the response path.
  function envoy_on_response(response_handle)
  end