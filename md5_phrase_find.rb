require 'digest'

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

def remove_chars(sub_str, full_str)
  sub_str.gsub!(/[^a-z]/i, "")
  full_str.gsub!(/[^a-z]/i, "")
  if can_build(sub_str, full_str)
    full_str.slice!(full_str.index(sub_str.chr))
    sub_str.slice!(0)
    if sub_str.length > 0 && full_str.length > 0
      sub_str.length > 0
      remove_chars(full_str, sub_str)
    else
      if full_str.length == 0
        ""
      else
        full_str
      end
    end
  else
    false
  end
end

def match_words(phrase, word)
end

def count_chars(input_str)
  input_str.gsub(/[^a-z]/i, "").length
end

def compare_char_count(input_str_one, input_str_two)
  count_chars(input_str_one) == count_chars(input_str_two) ? true : false
end

def verify_phrase(phrase, correct_md5_hash)
  md5_phrase = Digest::MD5.hexdigest(phrase)
  md5_phrase == correct_md5_hash ? true : false
end

correct_md5 = "4624d200580677270a54ccff86b9610e"
anagram = "poultry outwits ants"
valid_wordlist = []
phrases = []
leftovers = []

unless File.exists?("wordlist")
  puts "Wordlist not found, exiting..."
  abort
end

###################################################################
# STEP ONE: find the valid words based on letters in the anagram. #
###################################################################
unless File.exists?("scrubbed_wordlist")
  # Open the word list.
  # Only push the ones that don't contain a letter we know isn't in the anagram.
  # Double negetives ftw.
  print "Scrubbing word list of words that contain characters not found in the anagram...  "
  File.open("wordlist", "r") do |f|
    f.each_line do |line|
      if line.match(/(b|c|d|e|f|g|h|j|k|q|v|x|z)/i)
        # Nothing, we don't need these words.
      else
        valid_wordlist.push(line.chomp)
      end
    end
  end
  puts "DONE"

  ##################################################################################################################
  # STEP TWO: Of words with valid letters, which can be constructed using the quantities available in the anagram? #
  ##################################################################################################################
  print "Scrubbing word list of words which cannot be created using the available characters...  "
  valid_wordlist.each_with_index do |x, i|
    if can_build(x.clone, anagram.clone)
      # So, can_build cycles through letter by letter and ensures that one phrase
      # has enough letter in it to build the other.
      # For the purposes of keeping the word list in tact, apostrophe is included in anagram.
      # leftovers.push(remove_chars(x.clone, anagram.clone))
    else
      # Set the invalid ones as nil so that we can remove them later without impacting the iteration order.
      # i.e.; If we start deleting items from the array we're iterating through RIGHT NOW, it will start jumping around.
      valid_wordlist[i] = nil
    end
  end
  puts "DONE"
  # Compact already removes all nil items from the array for us. Just make sure there are nil items to remove,
  # Otherwise compact won't return what we think it will.
  print "Compacting wordlist... "
  valid_wordlist.compact! == nil ? valid_wordlist.compact! : false
  # Same kind of thing for unique items in the array.
  valid_wordlist.uniq! == nil ? valid_wordlist.uniq! : false
  # Save the results.
  puts "DONE"

  print "Writing valid wordlist to file... "
  File.write('scrubbed_wordlist', valid_wordlist.join("\n"))
  puts "DONE"
end

# Load scrubbed wordlist.
print "Scrubbed wordlist found, loading...  "
File.open("scrubbed_wordlist", "r") do |f|
  f.each_line do |line|
    valid_wordlist.push(line.chomp)
  end
  puts "DONE"
end

valid_wordlist.each do |w|
  if can_build(w.clone, anagram.clone)
    phrases.push w
    if remove_chars(w.clone, anagram.clone) != false
      leftovers.push remove_chars(w.clone, anagram.clone)
    elsif remove_chars(w.clone, anagram.clone) == false
      leftovers.push("")
    end
  end
end

phrases.each_with_index do |p, i|
  valid_wordlist.each do |w|
    puts "#{w} : #{leftovers[i]}"
    if can_build(w.clone, leftovers[i])
      phrases[i] += w
      leftovers[i] = remove_chars(w, leftovers[i])
    end
  end
end

puts phrases.inspect

######################################################################################################
# STEP THREE: Permutate and then check the words from the wordlist.                                  #
# The end value of the permutation length is set to the total number of words, so we don't miss any. #
# BUT it will stop permutating before it reaches the maximum level...                                #
######################################################################################################
# puts "Permutating valid words..."
# (1..valid_wordlist.length).each do |x|
#   puts "Beginning Permutation Level: #{x} Words"
#   valid_wordlist.permutation(x).each do |combination|
#     # So, I could run a bunch of check here, and then push those into an array.
#     # It's more accurate, right? You could just have it verify the character count and also can_build it,
#     # so only the actually feasible combinations get passed along.

#     # There are two major problems with this though:
#     # 1) We're already iterating. Why would we do two checks and then iterate again later
#     # when we can just do one check now and possible get the answer and end the script?

#     # 2) This would require some kind of permutation length ceiling.
#     # If we don't put a ceiling in, it will permutate through EVERY combination for all 'however many thousand'
#     # words in the dict before it even starts to look for a match with the MD5 hash. And that will take a LONG time.
#     # But if we add in a ceiling, it's possible we'll miss the phrase altogether. How can you know ahead of time?
#     # What if it was like 7 small words? Then you'll have to rerun it over and over,
#     # increasing the ceiling by 1 each time. And THAT's more time consuming than the below looping and blocking.
#     if verify_phrase(combination.join(" "), correct_md5)
#       puts "Phrase found! : \"#{combination.join(' ')}\""
#       # Let's just abort here, because if we don't, then it will keep doing it's permutation... D:
#       # Could also do a break unless chain, but I like this better, since there's literally no other steps left.
#       abort
#     end
#   end
# end