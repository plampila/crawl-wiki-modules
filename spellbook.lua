local p = {}

local book_data = mw.loadData('Module:Table of spellbooks')
local spell_data = mw.loadData('Module:Table of spells')

local function table_keys_sorted(t)
  local keys = {}
  for k in pairs(t) do
    table.insert(keys, k)
  end
  table.sort(keys)
  return keys
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

function p.spellbook_table(frame)
  local book = frame.args[1]
  if not book then
    return ""
  end
  local result = [==[{| cellpadding="5" border="1"
|- align="center"
! Tile || Spell || Type || Level
]==]
  local letters = 'abcdefghijklmnopqrstuvwxyz'
  for i,name in pairs(book_data[book].spells) do
    result = result .. "|-\n| [[File:" .. name:lower() .. ".png]] || " ..
       letters:sub(i, i) .. " - [[" .. name .. "]] || " ..
       format_schools(spell_data[name].schools) .. " || " ..
       spell_data[name].level .. "\n"
  end
  result = result .. "|}\n"
  return result
end

function p.short_spell_list(frame)
  local book = frame.args[1]
  if not book then
    return ""
  end
  local school = frame.args[2]
  if school == "" then school = nil end
  local result = "'''[[" .. book .. "]]''': "
  local spell_list = {}
  for _,name in pairs(book_data[book].spells) do
    if school == nil or spell_data[name]["schools"][school] then
      table.insert(spell_list, "[[".. name .. "]]")
    end
  end
  result = result .. table.concat(spell_list, ", ")
  return result
end

function p.spell_sources(frame)
  local school = frame.args[1]
  local primary_books = frame.args[2]

  local done = {}
  local ret = ""
  if primary_books ~= nil and primary_books ~= "" then
    ret = ret .. ";Main Texts\n"
    for book in string.gmatch(primary_books, "[^,]+") do
      ret = ret .. ":" .. frame:expandTemplate{title = "spellbook2", args = {book, school}} .. "\n"
      done[book] = true
    end
  end

  local found = {}
  for _,spell in pairs(spell_data) do
    if spell['schools'][school] then
      for book in pairs(spell['books']) do
        if not done[book] and not found[book] then
          found[book] = true
        end
      end
    end
  end

  if next(found) ~= nil then
    ret = ret .. ";Other Texts\n"
    -- TODO: ignore "the" while sorting
    for _,book in ipairs(table_keys_sorted(found)) do
      ret = ret .. ":" .. frame:expandTemplate{title = "spellbook2", args = {book, school}} .. "\n"
    end
  end

  return ret:sub(1, -2)
end

return p
