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

-- Used in Template:Schoollink
function p.school_to_skill(frame)
  local school = frame.args[1]
  if school == 'Poison' or school == 'Air' or school == 'Fire' or
     school == 'Ice' or school == 'Earth' then
    return school .. ' Magic'
  elseif school:sub(-1) == 'y' or school:sub(-1) == 's' then
    -- "Necromancy" isn't pluralised as a skill, and "Hexes" and "Charms" are
    -- already pluralized as a magic school. The others are singular as a
    -- school, plural as a skill.
    return school
  else
    return school .. 's'
  end
end

return p
