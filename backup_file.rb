require 'digest'
# To check the hash results of finalist phrases against the valid one.

# Anagram: "poultry outwits ants"
# Principe letters are a,i,l,n,o,p,r,s,t,u,w,y
# Invalid letters are b,c,d,e,f,g,h,j,k,q,v,x,z
# The MD5 hash of the secret phrase is "4624d200580677270a54ccff86b9610e"

def build_word(base_word_arry, available_letters_arry)
  if available_letters_arry.include?(base_word_arry[0])
    available_letters_arry.slice!(available_letters_arry.index(base_word_arry[0]))
    base_word_arry.slice!(0)
    if base_word_arry.length > 0 && available_letters_arry.length > 0
      build_word(base_word_arry, available_letters_arry)
    else
      return true
    end
  else
    return false
  end
end

def remove_chars(full_arry, sub_arry)
  while full_arry.class == Array && full_arry.length > 0
    full_arry.slice!(full_arry.index(sub_arry.first))
    sub_arry.slice!(0)
    if sub_arry.length > 0
      sub_arry.length > 0
      remove_chars(full_arry, sub_arry)
    else
      full_arry
    end
  end
  full_arry
end

def verify_phrase(phrase, correct_md5_hash)
  md5_phrase = Digest::MD5.hexdigest(phrase)
  md5_phrase == correct_md5_hash ? true : false
end

correct_md5 = "4624d200580677270a54ccff86b9610e"
anagram = "poultry outwits ants"
anagram_letters =  "poultryoutwitsants'"
all_chars = "ailnooprssttttuuwy'"
valid_wordlist = []
w_words = []
non_w_words = []
leftovers = []

###################################################################
# STEP ONE: find the valid words based on letters in the anagram. #
###################################################################
unless File.exists?("scrubbed_wordlist")
  # Open the word list.
  # Only push the ones that don't contain a letter we know isn't in the anagram.
  # Double negetives ftw.
  File.open("wordlist", "r") do |f|
    f.each_line do |line|
      if line.match(/(b|c|d|e|f|g|h|j|k|q|v|x|z)/i) || line.length > 18
        # Nothing, we don't need these words.
      else
        valid_wordlist.push(line.chomp)
      end
    end
  end

  ##################################################################################################################
  # STEP TWO: Of words with valid letters, which can be constructed using the quantities available in the anagram? #
  ##################################################################################################################
  valid_wordlist.each_with_index do |x, i|
    if build_word(x.split(""), anagram_letters.split(""))
      # So, build_word cycles through letter by letter and ensures that one phrase
      # has enough letter in it to build the other.
      # For the purposes of keeping the word list in tact, apostrophe is included in anagram_letters.
    else
      # Set the invalid ones as nil so that we can remove them later without impacting the iteration order.
      # i.e.; If we start deleting items from the array we're iterating through RIGHT NOW, it will start jumping around.
      valid_wordlist[i] = nil
    end
  end

  # Compact already removes all nil items from the array for us. Just make sure there are nil items to remove,
  # Otherwise compact won't return what we think it will.
  valid_wordlist.compact! == nil ? valid_wordlist.compact! : false
  # Same kind of thing for unique items in the array.
  valid_wordlist.uniq! == nil ? valid_wordlist.uniq! : false
  # Save the results.
  File.write('scrubbed_wordlist', valid_wordlist.join("\n"))
end

# Load scrubbed wordlist.
File.open("scrubbed_wordlist", "r") do |f|
  f.each_line do |line|
    valid_wordlist.push(line.chomp)
  end
end

###########################################################################################################
# STEP THREE: 'w' is the letter which appears the LEAST in the word list, out of all the anagram letters. #
#             So, extract all the 'w' words, and one of the results is guaranteed to be in the phrase.    #
###########################################################################################################
unless File.exists?("w_wordlist") && File.exists?("non_w_wordlist") && File.exists?("leftovers")
  valid_wordlist.each do |line|
    if line.match(/[w]/i) == nil
      # non_w_words list is important to see what words can be built using the remaining letters,
      # after the ones for the 'w' word are removed.
      non_w_words.push(line.chomp)
    else
      w_words.push(line.chomp)
    end
  end

  # Remove the characters in each 'w' word from the full list of letters to see what's left to work with
  w_words.each do |word|
    leftovers.push(remove_chars(all_chars.split(""), word.gsub(/[^a-zA-Z]/i, "").split("")).join(""))
  end

  File.write('w_wordlist', w_words.join("\n"))
  File.write('non_w_wordlist', non_w_words.join("\n"))
  File.write('leftovers', leftovers.join("\n"))
end

# Load w-words wordlist.
File.open("w_wordlist", "r") do |f|
  f.each_line do |line|
    w_words.push(line.chomp)
  end
end

# Load non-w-words wordlist.
File.open("non_w_wordlist", "r") do |f|
  f.each_line do |line|
    non_w_words.push(line.chomp)
  end
end

# Load leftover characters list.
File.open("leftovers", "r") do |f|
  f.each_line do |line|
    leftovers.push(line.chomp)
  end
end

####################################################################################################################
# STEP FOUR: Iterate through every 'w' word, and see what phrases are possible to make with the remaining letters. #
####################################################################################################################
# start with each word I at least one of has to be in the phrase
# add each word which can be added as the second word to the string
# remove THOSE used characters
# continue with the third word
# keep going until there are no more words that can be added
# save this as a phrase combination
# move on to the next word
# do this until no more words can be added

def count_chars(input_str)
  arry = input_str.gsub(/[a-zA-Z]/i, "").length
end

def compare_char_count(input_str_one, input_str_two)
  count_characters(input_str_one) == count_chars(input_str_two) ? true : false
end