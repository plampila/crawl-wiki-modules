local p = {}

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
  local result = "'''[[" .. book .. "]]''': "
  local spell_list = {}
  for _,sp in ipairs(data[book]) do
    table.insert(spell_list, "[[".. sp.name .. "]]")
  end
  result = result .. table.concat(spell_list, ", ")
  return result
end

return p
