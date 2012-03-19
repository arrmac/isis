require 'twss'
require 'isis/plugins/base'

# Monkeypatching TWSS library to return
# value instead of true/false, so that
# we can tailor chat messages based on
# magnitude of she-said-it-ness
#
module TWSS
  class Engine
    def classify(str)
      if basic_conditions_met?(str)
        c = @classifier.classifications(str)
        require 'pp'
        # c[TRUE] - c[FALSE] > threshold
        c[TRUE] - c[FALSE]
      else
        # false
        0.0
      end
    end
  end
end

class Isis::Plugin::TWSS < Isis::Plugin::Base

  def initialize
    @ignored_speakers = ["Git", "The Greenbook"]
  end

  def respond_to_msg?(msg, speaker)
    # don't bother parsing if it's a command string
    if msg[0] == "!"
      false
    elsif @ignored_speakers.include?(speaker)
      false
    else
      @shesaid = TWSS(msg)
      puts "TWSS(#{"%.3f" % @shesaid}): #{msg}\n"
      @shesaid
    end
  end

  def response
    case @shesaid
    when 16..25
      "That's what she said!"
    when 26..99
      "THAT'S WHAT SHE SAID!!"
    else
      nil
    end
  end
end
