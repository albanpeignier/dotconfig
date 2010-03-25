require 'irb/completion'

require 'irb/ext/save-history'
IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb-save-history"

# load rubygems, and utility_belt
require 'rubygems'
require 'utility_belt'    

UtilityBelt.equip(:define_model_find_shortcuts)

