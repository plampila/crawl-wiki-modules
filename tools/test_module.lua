mw = {}
function mw.loadData(name)
  return require(name:lower():gsub(' ', '_'):gsub('module:_?', '', 1))
end

local frame = {}
frame.args = {}
function frame.expandTemplate(_, data)
  return '{{' .. data.title .. '}}'
end

if #arg < 1 then
  print('Usage: ' .. arg[0] .. ' <module> [function]')
  return 1
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
