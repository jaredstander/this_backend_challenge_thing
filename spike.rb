def can_build(base_word, available_letters)
  base_word.gsub!(/[^a-z]/i, "")
  available_letters.gsub!(/[^a-z]/i, "")
  if available_letters.include?(base_word.chr)
    available_letters.slice!(available_letters.index(base_word.chr))
    base_word.slice!(0)
    if base_word.length > 0 && available_letters.length > 0
      can_build(base_word, available_letters)
    else
      return true
    end
  else
    return false
  end
end

# Fix this shit
def remove_chars(base_word, available_letters)
  base_word.gsub!(/[^a-z]/i, "")
  available_letters.gsub!(/[^a-z]/i, "")
  if available_letters.include?(base_word.chr)
    available_letters.slice!(available_letters.index(base_word.chr))
    base_word.slice!(0)
    if base_word.length > 0
      remove_chars(base_word, available_letters)
    else
      available_letters
    end
  else
    false
  end
end
# /fix this shit

# def remove_chars(sub_str, full_str)
#   sub_str.gsub!(/[^a-z]/i, "")
#   full_str.gsub!(/[^a-z]/i, "")
#   if can_build(sub_str, full_str)
#     full_str.slice!(full_str.index(sub_str.chr))
#     sub_str.slice!(0)
#     if sub_str.length > 0 && full_str.length > 0
#       sub_str.length > 0
#       remove_chars(full_str, sub_str)
#     else
#       if full_str.length == 0
#         ""
#       else
#         full_str
#       end
#     end
#   else
#     false
#   end
# end

one = "pat's"
two = "poultryoutwitsants"
puts can_build(one, two)
puts remove_chars(one, two)