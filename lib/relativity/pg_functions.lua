local c, of, f, sql
do
  local _obj_0 = require('relativity')
  c, of, f, sql = _obj_0.cast, _obj_0.opt_func, _obj_0.func, _obj_0.sql
end
local abs = math.abs
local localtimestamp = f('localtimestamp')
local LOCALTIMESTAMP
LOCALTIMESTAMP = function()
  return localtimestamp(6)
end
local interval
interval = function(spec)
  return c(spec, 'interval')
end
return {
  ts_rank = f('ts_rank'),
  to_tsquery = f('to_tsquery'),
  coalesce = f('COALESCE'),
  distinct = f('DISTINCT'),
  any = f('ANY'),
  to_json = f('to_json'),
  json_build_object = of('json_build_object'),
  array_agg = f('array_agg'),
  concat = f('concat'),
  localtimestamp = localtimestamp,
  LOCALTIMESTAMP = LOCALTIMESTAMP,
  interval = interval,
  from_now = function(num, spec)
    local sign = num < 0 and '-' or '+'
    local abs_num = abs(num)
    return sql(LOCALTIMESTAMP():to_sql() .. " " .. tostring(sign) .. " " .. interval(tostring(abs_num) .. " " .. tostring(spec)):to_sql())
  end
}
