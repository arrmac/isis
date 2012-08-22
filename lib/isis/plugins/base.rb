# Plugin base class

module Isis
  module Plugin
    class Base
      def receive_message(msg, speaker)
        respond_to_msg?(msg, speaker) ? response : nil
      end
    end
  end
end
