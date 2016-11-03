if #arg < 1 then
  print('Usage: ' .. arg[0] .. ' <module> [function] [arguments...]')
  return 1
end

mw = {}
function mw.loadData(name)
  return require(name:lower():gsub(' ', '_'):gsub('module:_?', '', 1))
end

local frame = {}
frame.args = {}
for i=3,#arg,1 do
  frame.args[i - 2] = arg[i]
end
function frame.expandTemplate(_, data)
  local ret = '{{' .. data.title
  for y,x in pairs(data.args) do
    if type(y) == 'number' then
      ret = ret .. '|' .. x
    else
      ret = ret .. '|' .. y .. '=' .. x
    end
  end
  return ret .. '}}'
end

local module = require(arg[1])

if #arg >= 2 then
  print(module[arg[2]](frame))
else
  for name,func in pairs(module) do
    print('Testing function: ' .. name)
    func(frame)
  end
end
