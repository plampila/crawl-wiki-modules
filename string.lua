local p = {}
 
function p.first_word(frame)
  local text = frame.args[1]
  for token in string.gmatch(text, "[^%s]+") do
    return token
  end
end

return p
