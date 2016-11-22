local p = {}
local data = mw.loadData('Module: Table of spells')
local RANGE_LOS = 7

local function table_keys_sorted(t, f)
  local keys = {}
  for k in pairs(t) do
    table.insert(keys, k)
  end
  table.sort(keys, f)
  return keys
end

local function empty_table(t)
  for _ in pairs(t) do
    return false
  end
  return true
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

local function format_schools(frame, schools, no_link_for)
  local ret = ''
  for _, school in ipairs(table_keys_sorted(schools)) do
    if school == no_link_for then
      ret = ret .. school .. '/'
    else
      ret = ret ..
        frame:expandTemplate{title = 'schoollink', args = {school}} .. '/'
    end
  end
  return ret:sub(1, -2)
end

local function format_range(range)
  if range == nil then
    return ''
  elseif range.min == range.max then
    if range.min == RANGE_LOS then
      return 'LOS'
    else
      return range.min
    end
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

local function format_flags(flags, ignored)
  if flags == nil then
    return ''
  end
  local ret = ''
  for _, flag in ipairs(table_keys_sorted(flags)) do
    if not ignored or not ignored[flag] then
      ret = ret .. format_flag(flag) .. ', '
    end
  end
  return ret:sub(1, -3)
end

local function compare_books(a, b)
  return a:lower():gsub('^book of ', ''):gsub('^a ', ''):gsub('^the ', '') <
    b:lower():gsub('^book of ', ''):gsub('^a ', ''):gsub('^the ', '')
end

local function format_books(books)
  local ret = ''
  for _, book in ipairs(table_keys_sorted(books, compare_books)) do
    ret = ret .. '[[' .. book:gsub('^%l', string.upper) .. ']]<br>'
  end
  return ret:sub(1, -5)
end

local function spell_table_line(frame, name, info, no_link_for)
  return '|[[File:' .. name:lower() .. '.png]]\n' ..
         '|style="padding-left:1em"|[[' .. name .. ']]\n' ..
         '|' .. format_schools(frame, info['schools'], no_link_for) .. '\n' ..
         '|' .. info['level'] .. '\n' ..
         '|' .. (info['power cap'] == 0 and 'N/A' or info['power cap']) ..
         '\n' ..
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
    ret = ret .. spell_table_line(frame, name, data[name])
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
          ret = ret .. spell_table_line(frame, name, data[name], school)
        end
      end
    end
  end
  return ret .. '|}'
end

function p.spell_table_by_school(frame)
  local schools = {}
  for _,spell in pairs(data) do
    for school in pairs(spell['schools']) do
      schools[school] = true
    end
  end

  local ret = '==Spells==\n' .. spell_table_header()
  for _,school in ipairs(table_keys_sorted(schools)) do
    ret = ret .. spell_table_section(
      frame:expandTemplate{title = 'schoollink', args = {school}})
    for _, name in ipairs(names_by_level(data)) do
      if data[name]['schools'][school] then
        ret = ret .. spell_table_line(frame, name, data[name], school)
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
  for _,book in ipairs(table_keys_sorted(books, compare_books)) do
    ret = ret ..
      spell_table_section('[[' .. book:gsub('^%l', string.upper) .. ']]')
    for _, name in ipairs(names_by_level(data)) do
      if data[name]['books'][book] then
        ret = ret .. spell_table_line(frame, name, data[name])
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
    if empty_table(data[name]['flags']) then
      ret = ret .. spell_table_line(frame, name, data[name])
    end
  end

  for _, flag in ipairs(table_keys_sorted(flags)) do
    ret = ret .. spell_table_section(format_flag(flag)) ..
      '| colspan=9 |' ..
      frame:expandTemplate{title = 'SpellFlagDesc ' .. format_flag(flag),
        args = {}} ..
      '\n|----\n'
    for _, name in ipairs(names_by_level(data)) do
      if data[name]['flags'][flag] then
        ret = ret .. spell_table_line(frame, name, data[name])
      end
    end
  end
  return ret .. '|}'
end

local function format_hated_by(spell)
  local output = ''
  if spell.flags.HASTY then
    output = output .. '[[Cheibriados]][[Category:Hasty Spells]]<br>'
  end
  if spell.schools.Fire then
    output = output .. '[[Dithmenos]]<br>'
  end
  if spell.flags.CORPSE_VIOLATING then
    output = output .. '[[Fedhas]][[Category:Corpse Violating Spells]]<br>'
  end
  if spell.flags.UNHOLY or spell.schools.Necromancy then
    output = output .. '[[Elyvilon]]<br>'
  end
  if spell.flags.UNHOLY or spell.schools.Necromancy or spell.schools.Poison then
    output = output .. '[[The Shining One]]<br>'
  end
  if spell.name == 'Statue Form' then
    output = output .. '[[Yredelemnul]]<br>'
  end
  if spell.flags.CHAOTIC or spell.flags.UNCLEAN or spell.flags.UNHOLY or
    spell.schools.Necromancy then
    output = output .. '[[Zin]]'
    if spell.flags.UNCLEAN then
      output = output .. '[[Category:Unclean Spells]]'
    end
    if spell.flags.CHAOTIC then
      output = output .. '[[Category:Chaotic Spells]]'
    end
    if spell.flags.UNHOLY then
      output = output .. '[[Category:Unholy Spells]]'
    end
    output = output .. '<br>'
  end
  return output:sub(1, -5)
end

local function format_targetting(flags)
  local style = nil
  if flags.DIR then
    style = 'Direction'
  elseif flags.DIR_OR_TARGET then
    style = 'Target or direction'
  elseif flags.TARGET then
    style = 'Smite'
  end
  if style then
    if flags.OBJ and flags.NOT_SELF then
      return style .. ' (object, not self)'
    elseif flags.OBJ then
      return style .. ' (object)'
    elseif flags.NOT_SELF then
      return style .. ' (not self)'
    end
  end
  return style
end

function p.spell_info(frame)
  local name = frame.args[1]
  if not name or name == '' then
    name = mw.title.getCurrentTitle().text
  end
  local spell = data[name]
  if not spell then
    return name
  end

  local args = {}
  args.name = spell.name
  args.level = spell.level
  for i,school in ipairs(table_keys_sorted(spell.schools)) do
    args['school' .. i] =
      frame:expandTemplate{title = 'schoollink', args = {school}} ..
      '[[Category:' .. school .. ' Spells]]'
    i = i + 1
  end
  args.sources = format_books(spell.books)
  args.castingnoise = spell.noise.casting
  args.spellnoise = spell.noise.effect
  args['power cap'] = spell['power cap'] == 0 and 'N/A' or spell['power cap']
  args.targetting = format_targetting(spell.flags)
  args.range = format_range(spell.range)
  args.rarity = spell.rarity
  args['hated by'] = format_hated_by(spell)
  args.flags = format_flags(spell.flags, {
    CHAOTIC = true,
    CORPSE_VIOLATING = true,
    DIR = true,
    DIR_OR_TARGET = true,
    HASTY = true,
    MONS_ABJURE = true,
    NEEDS_TRACER = true,
    NOT_SELF = true,
    OBJ = true,
    TARGET = true,
    UNCLEAN = true,
    UNHOLY = true,
  })

  local infobox = frame:expandTemplate{title = 'spell', args = args}

  local flavour = spell.description
  if spell.quote then
    flavour = flavour .. '\n----\n' .. spell.quote:gsub('\n', '<br>')
  end
  flavour = frame:expandTemplate{title = 'flavour', args = {flavour}}
  return infobox .. '\n' .. flavour
end

return p
