local p = {}

local function table_has_value(t, v)
  if t ~= nil then
    for _,x in pairs(t) do if x == v then return true end end
  end
  return false
end

local function table_keys_sorted(t)
  local keys = {}
  for k in pairs(t) do
    table.insert(keys, k)
  end
  table.sort(keys)
  return keys
end

function p.spellbook_table(frame)
  local data = mw.loadData('Module:Table of spellbooks')
  local book = frame.args[1]
  if not book then
    return ""
  end
  local result = [==[{| cellpadding="5" border="1"
|- align="center"
! Tile || Spell || Type || Level
]==]
  for _,sp in ipairs(data[book]) do
    result = result .. "|-\n| " .. sp.image .. " || " ..
       sp.letter .. " - [[" .. sp.name .. "]] || " .. sp.schools .. 
       " || " .. sp.level .. "\n"
  end
  result = result .. "|}\n"
  return result
end

function p.short_spell_list(frame)
  local data = mw.loadData('Module:Table of spellbooks')
  local book = frame.args[1]
  if not book then
    return ""
  end
  local school = frame.args[2]
  if school == "" then school = nil end
  local spell_data = nil
  if school ~= nil then
    spell_data = mw.loadData('Module:Table of spells')
  end
  local result = "'''[[" .. book .. "]]''': "
  local spell_list = {}
  for _,sp in ipairs(data[book]) do
    if school == nil or table_has_value(spell_data[sp.name]["schools"], school) then
      table.insert(spell_list, "[[".. sp.name .. "]]")
    end
  end
  result = result .. table.concat(spell_list, ", ")
  return result
end

function p.spell_sources(frame)
  local spell_data = mw.loadData('Module:Table of spells')

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
    if table_has_value(spell['schools'], school) then
      for _,book in pairs(spell['books']) do
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
