local p = {}
local data = mw.loadData('Module: Table of spells')

local function table_keys_sorted(t)
  local keys = {}
  for k in pairs(t) do
    table.insert(keys, k)
  end
  table.sort(keys)
  return keys
end

local function names_by_level()
  local names = table_keys_sorted(data)
  table.sort(names, function(a, b)
    if data[a].level == data[b].level then
      return a < b
    else
      return data[a].level < data[b].level
    end
  end)
  return names
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

local function format_schools(schools, no_link_for)
  local ret = ''
  for school in pairs(schools) do
    if school == no_link_for then
      ret = ret .. school .. '/'
    else
      ret = ret .. spell_school_link(school) .. '/'
    end
  end
  return ret:sub(1, -2)
end

local function format_range(range)
  if range == nil then
    return ''
  elseif range.min == range.max then
    return range.min
  else
    return range.min .. '-' .. range.max
  end
end

local function format_noise(noise)
  if noise == nil then
    return ''
  else
    return math.max(noise.casting, noise.effect)
  end
end

local function format_flag(flag)
  if flag == 'MR_CHECK' then
    return 'MR check'
  else
    return flag:gsub('_', ' '):lower():gsub('^%l', string.upper)
  end
end

local function format_flags(flags)
  if flags == nil then
    return ''
  end
  local ret = ''
  for flag in pairs(flags) do
    ret = ret .. format_flag(flag) .. ', '
  end
  return ret:sub(1, -3)
end

local function format_books(books)
  local ret = ''
  for book in pairs(books) do
    ret = ret .. '[[' .. book .. ']]<br>'
  end
  return ret:sub(1, -5)
end

local function spell_table_line(name, info, no_link_for)
  return '|[[File:' .. name:lower() .. '.png]]\n' ..
         '|style="padding-left:1em"|[[' .. name .. ']]\n' ..
         '|' .. format_schools(info['schools'], no_link_for) .. '\n' ..
         '|' .. info['level'] .. '\n' ..
         '|' .. info['power cap'] .. '\n' ..
         '|' .. format_range(info['range']) .. '\n' ..
         '|' .. format_noise(info['noise']) .. '\n' ..
         '|' .. format_flags(info['flags']) .. '\n' ..
         '|' .. format_books(info['books']) .. '\n' ..
         '|----\n'
end

function p.spell_table(frame)
  local alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

  local ret = '==Spells==\n' .. spell_table_header()
  local c = nil
  for _, name in ipairs(table_keys_sorted(data)) do
    if name:sub(1, 1) ~= c then
      c = name:sub(1, 1)
      ret = ret .. spell_table_section(c)
    end
    ret = ret .. spell_table_line(name, data[name])
  end
  return ret .. '|}'
end

function p.spell_table_by_level(frame)
  local school = frame.args[1]
  if school == '' then
    school = nil
  end
  local ret = '==Spells==\n' .. spell_table_header()
  for level=1,9 do
    local found = false
    for _, name in ipairs(table_keys_sorted(data)) do
      if data[name]['level'] == level then
        if school == nil or data[name]['schools'][school] then
          if not found then
            found = true
            ret = ret .. spell_table_section('Level ' .. level)
          end
          ret = ret .. spell_table_line(name, data[name], school)
        end
      end
    end
  end
  return ret .. '|}'
end

function p.spell_table_by_school(frame)
  local schools = { 'Air', 'Charms', 'Conjuration', 'Earth', 'Fire', 'Hexes',
    'Ice', 'Necromancy', 'Poison', 'Summoning', 'Translocation',
    'Transmutation' }

  local ret = '==Spells==\n' .. spell_table_header()
  for _,school in ipairs(schools) do
    ret = ret .. spell_table_section(spell_school_link(school))
    for _, name in ipairs(names_by_level(data)) do
      if data[name]['schools'][school] then
        ret = ret .. spell_table_line(name, data[name], school)
      end
    end
  end
  return ret .. '|}'
end

function p.spell_table_by_book(frame)
  local books = {}
  for _,spell in pairs(data) do if spell['books'] ~= nil then
    for book in pairs(spell['books']) do
      books[book] = true
    end
  end end

  local ret = '==Spells==\n' .. spell_table_header()
  for _,book in ipairs(table_keys_sorted(books)) do
    ret = ret .. spell_table_section('[[' .. book .. ']]')
    for _, name in ipairs(names_by_level(data)) do
      if data[name]['books'][book] then
        ret = ret .. spell_table_line(name, data[name])
      end
    end
  end
  return ret .. '|}'
end

function p.spell_table_by_flag(frame)
  local flags = {}
  for _,spell in pairs(data) do if spell['flags'] ~= nil then
    for flag,_ in pairs(spell['flags']) do
      flags[flag] = true
    end
  end end

  local ret = '==Spells==\n' .. spell_table_header()

  ret = ret .. spell_table_section('No flags')
  for _, name in ipairs(names_by_level(data)) do
    if next(data[name]['flags']) == nil then
      ret = ret .. spell_table_line(name, data[name])
    end
  end

  for _,flag in ipairs(table_keys_sorted(flags)) do
    ret = ret .. spell_table_section(format_flag(flag)) ..
      '| colspan=9 |' ..
      frame:expandTemplate{title = 'SpellFlagDesc ' .. format_flag(flag),
        args = {}} ..
      '\n|----\n'
    for _, name in ipairs(names_by_level(data)) do
      if data[name]['flags'][flag] then
        ret = ret .. spell_table_line(name, data[name])
      end
    end
  end
  return ret .. '|}'
end

return p
