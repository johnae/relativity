{cast: c, opt_func: of, func: f, :sql} = require'relativity'

abs = math.abs

localtimestamp = f'localtimestamp'
LOCALTIMESTAMP = -> localtimestamp 6
interval = (spec) -> c spec, 'interval'

{
  ts_rank: f'ts_rank'
  to_tsquery: f'to_tsquery'
  coalesce: f'COALESCE'
  any: f'ANY'
  to_json: f'to_json'
  json_build_object: of'json_build_object'
  array_agg: f'array_agg'
  concat: f'concat'
  :localtimestamp
  :LOCALTIMESTAMP
  :interval
  from_now: (num, spec) ->
    sign = num < 0 and '-' or '+'
    abs_num = abs num
    sql LOCALTIMESTAMP!\to_sql! .. " #{sign} " .. interval"#{abs_num} #{spec}"\to_sql!
}
