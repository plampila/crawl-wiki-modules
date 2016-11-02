local p = {}
local data = mw.loadData('Module: Table of spells')
local spell_names = {}
for k in pairs(data) do
  table.insert(spell_names, k)
end
table.sort(spell_names)

local function table_has_value(t, v)
  for _,x in pairs(t) do if x == v then return true end end
  return false
end

local function spell_table_header()
  return [=[{| class="prettytable"
!|Icon
!|Name
!|Schools
!|Level
!|Power<br>cap
!|Range
!|Noise
!|Flags
!|Books
|----
]=]
end

local function spell_table_section(heading)
  return '! colspan=9 style="text-align:left"|\n' ..
         '====' .. heading .. '====\n' ..
         '|----\n'
end

local function spell_school_link(school)
  local skill = nil
  if school == 'Poison' or school == 'Air' or school == 'Fire' or
     school == 'Ice' or school == 'Earth' then
    skill = school .. ' Magic'
  elseif school:sub(-1) ~= 'y' and school:sub(-1) ~= 's' then
      -- "Necromancy" isn't pluralised as a skill,
      -- and "Hexes" and "Charms" are already
      -- pluralized as a magic school.  The others
      -- are singular as a school, plural as a skill.
      skill = school .. 's'
  end

  if skill ~= nil then
    return '[[' .. skill .. '|' .. school .. ']]'
  else
    return '[[' .. school .. ']]'
  end
end

local function format_schools(schools)
  local ret = ''
  for _,school in pairs(schools) do
    ret = ret .. spell_school_link(school) .. '/'
  end
  return ret:sub(1, -2)
end

local function format_range(range)
  if range == nil then
    return ''
  elseif type(range) == 'table' then
    return range[1] .. '-' .. range[2]
  else
    return range
  end
end

local function format_flags(flags)
  if flags == nil then
    return ''
  end
  local ret = ''
  for _,flag in ipairs(flags) do
    ret = ret .. flag .. ', '
  end
  return ret:sub(1, -3)
end

local function format_books(books)
  local ret = ''
  for _,book in ipairs(books) do
    ret = ret .. '[[' .. book .. ']]<br>'
  end
  return ret:sub(1, -5)
end

local function spell_table_line(name, info)
  return '|[[File:' .. name:lower() .. '.png]]\n' ..
         '|style="padding-left:1em"|[[' .. name .. ']]\n' ..
         '|' .. format_schools(info['schools']) .. '\n' ..
         '|' .. info['level'] .. '\n' ..
         '|' .. info['cap'] .. '\n' ..
         '|' .. format_range(info['range']) .. '\n' ..
         '|' .. info['noise'] .. '\n' ..
         '|' .. format_flags(info['flags']) .. '\n' ..
         '|' .. format_books(info['books']) .. '\n' ..
         '|----\n'
end

function p.spell_table(frame)
  local alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

  local ret = '==Spells==\n' .. spell_table_header()
  local c = nil
  for _, name in ipairs(spell_names) do
      if name:sub(1, 1) ~= c then
        c = name:sub(1, 1)
        ret = ret .. spell_table_section(c)
      end
      ret = ret .. spell_table_line(name, data[name])
  end
  return ret .. '|}\n'
end

function p.spell_table_by_level(frame)
  local school = frame.args[1]
  if school == "" then
    school = nil
  end
  local ret = '==Spells==\n' .. spell_table_header()
  for level=1,9 do
    local found = false
    for _, name in ipairs(spell_names) do if data[name]["level"] == level then
      if school == nil or table_has_value(data[name]['schools'], school) then
        if not found then
          found = true
          ret = ret .. spell_table_section('Level ' .. level)
        end
        ret = ret .. spell_table_line(name, data[name])
      end
    end end
  end
  return ret .. '|}\n'
end

function p.spell_table_by_school(frame)
  table.sort(spell_names, function(a, b)
    if data[a].level == data[b].level then
      return a < b
    else
      return data[a].level < data[b].level
    end
  end)
  local schools = { 'Air', 'Charms', 'Conjuration', 'Earth', 'Fire', 'Hexes',
    'Ice', 'Necromancy', 'Poison', 'Summoning', 'Translocation',
    'Transmutation' }

  local ret = '==Spells==\n' .. spell_table_header()
  for _,school in pairs(schools) do
    ret = ret .. spell_table_section(school)
    for _, name in ipairs(spell_names) do
      if table_has_value(data[name]['schools'], school) then
        ret = ret .. spell_table_line(name, data[name])
      end
    end
  end
  return ret .. '|}\n'
end

return p
