local io = require('io')
local json = require('json')
local serpent = require('serpent'); -- https://github.com/pkulchenko/serpent

local data = json.decode.decode(io.read('*a'))

local sort_nocase  = function(k, o) -- k=keys, o=original table
  local maxn, to = 12, {number = 'a', string = 'b'}
  local function padnum(d) return ('%0'..maxn..'d'):format(d) end
  local sort = function(a,b)
    -- this -vvvvvvvvvv- is needed to sort array keys first
    return ((k[a] and 0 or to[type(a)] or 'z')..(tostring(a):gsub('%d+',padnum))):upper()
         < ((k[b] and 0 or to[type(b)] or 'z')..(tostring(b):gsub('%d+',padnum))):upper()
  end
  table.sort(k, sort)
end

if arg[1] == 'spells' then
  print('-- Table of spells (' .. data.version .. ')')
  print('return ' .. serpent.block(data.spells, {
    fatal = true,
    comment = false,
    sortkeys = sort_nocase,
  }))
elseif arg[1] == 'spellbooks' then
  print('-- Table of spell books (' .. data.version .. ')')
  print('return ' .. serpent.block(data.spellbooks, {
    fatal = true,
    comment = false,
    sortkeys = sort_nocase,
  }))
else
  io.stderr:write('Usage: ' .. arg[0] .. ' <module>\n');
  io.stderr:write('Available modules: spells, spellbooks\n');
end
