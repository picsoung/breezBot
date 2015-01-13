
-- fct to split a string by a delimeter
local function split(s, delimiter)
  local result = {}
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
    table.insert(result, match)
  end
  return result
end

local hex_to_char = function(x)
  return string.char(tonumber(x, 16))
end

local unescape = function(url)
  return url:gsub("%%(%x%x)", hex_to_char)
end

local postToSlack = function (params, URL)
  -- assemble the recommendation for each category with corresponding emoji
  local reco = "\xF0\x9F\x90\xA3 :"..params.recommendations.children.."\\n"
  reco = reco .. "\xE2\x9D\xA4 :"..params.recommendations.health.."\\n"
  reco = reco .. "\xF0\x9F\x8F\xA0 :"..params.recommendations.inside.."\\n"
  reco = reco .. "\xE2\x9B\xBA :"..params.recommendations.outside.."\\n"
  reco = reco .. "\xE2\x9A\xBD :"..params.recommendations.sport
	 local r = http.json.post(URL,'{"channel":"#'.. params.channel_name..'","name":"AirQualityBot","attachments":[{"fallback":"'..params.msg..'","pretext":"'..params.msg..'","color":"'..params.color..'","fields":[{"title":"Recommendations","value":"'..reco..'","short":false}]}]}')
   console.log('request to SLack',r)
end

local postErrorToSlack = function (params, URL)
   console.log("PARAMS",params)
	 local r = http.json.post(URL,'{"channel":"#'.. params.channel_name..'","name":"AirQualityBot","attachments":[{"fallback":"'..params.msg..'","pretext":"","color":"#FF0000","fields":[{"title":"Error","value":"'..params.msg..'","short":false}]}]}')
   console.log('request to Slack',r)
end

return function(request, next_middleware)
  local response = next_middleware()
  local hookURL = "SLACK_HOOK_URL"

  if(request.uri == '/hook') then
    local params = split(request.body,'&')
    local decoded_params = {}
    -- turn urlencoded string into an object
    for i=1,#params do
      local p = split(params[i],'=')
      decoded_params[p[1]] = p[2]
    end

    local query = decoded_params['text']
    query = unescape(query) -- decode special chars

    if(string.match(query,"^breez+[a-zA-Z0-9_,+ ]*")) then
      local city_name = string.sub(query,string.find(query, "breez+")+6)

			local url = "https://BREEZ_APITOOLS_URL?location="..city_name.."&key=BREEZ_API_KEY"
      local r = http.get(url)
      console.log(r)
      local body =json.decode(r.body)
      botParams = {}
      botParams.msg = ""
      botParams.channel_name = decoded_params.channel_name
      if(body.error) then
        botParams.msg = botParams.msg .. body.error
        postErrorToSlack(botParams,hookURL)
      else
        botParams.msg = botParams.msg .. body.breezometer_description .. " in ".. string.gsub(city_name,"+"," ") .." "..body.breezometer_aqi
        botParams.color = body.breezometer_color
        botParams.breezometer_description = body.breezometer_description
        botParams.recommendations = body.random_recommendations
        postToSlack(botParams, hookURL)
      end
    else
      botParams = {}
      botParams.msg = 'Malformated request. Format is: `breez CITY_NAME`'
      botParams.channel_name = decoded_params.channel_name
      local r = postErrorToSlack(botParams,hookURL)
      console.log(r)
    end
  end
  return response
end
