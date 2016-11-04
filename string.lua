local p = {}

-- Used in Template:Monster by Property:Hit_dice
function p.first_word(frame)
  local text = frame.args[1]
  for token in string.gmatch(text, '[^%s,]+') do
    return token
  end
end

-- Used in Template:Monster by Property:Monster_magic_resistance
function p.fix_magic_resistance(frame)
  local text = frame.args[1]
  if text == 'Immune' or text == 'immune' then
    return '1000'
  end
  return text
end

-- Used in Template:Monster by Property:Monster_size
function p.fix_monster_size(frame)
  local text = frame.args[1]
  found, _, token = string.find(text, '|([^%]]+)%]')
  if found then
    return token
  end
  return text
end

-- Used in Template:Monster by Property:Monster_intelligence
function p.fix_monster_intelligence(frame)
  return p.fix_monster_size(frame)
end

-- Used in Template:Armour
function p.fix_gdr(frame)
  local text = frame.args[1]
  new_text, _ = string.gsub(text, '%%', '')
  return new_text
end

return p
