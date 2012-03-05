# HipChat connection
# Uses HipChat's XMPP connection

require 'xmpp4r'
require 'xmpp4r/muc/helper/simplemucclient'
require 'isis/connections/base'
require 'isis/connections/xmpp4r-nohistory'

class Isis::Connections::HipChat < Isis::Connections::Base

  attr_accessor :client
  attr_accessor :muc

  def initialize(config)
    load_config(config)
    @client = Jabber::Client.new(@config['hipchat']['jid'])
    @muc = Jabber::MUC::SimpleMUCClient.new(client)
  end

  def send_jabber_presence
    @client.send(Jabber::Presence.new.set_type(:available))
  end

  def connect
    @client.connect
    @client.auth(@config['hipchat']['password'])
    send_jabber_presence
    @join_time = Time.now
  end

  def register_disconnect_callback
    @client.on_exception do |e, stream, where|
      puts "Exception! #{e.to_s}"
      self.connect  # Reconnect!
    end
  end

  def register_plugins(bot)
    @muc.on_message do |time, speaker, message|
      # |time| is useless - comes back blank
      # we must fend for ourselves

      sudo = message.match /^sudo (.+)/
      message = sudo[1] if sudo

      # ignore our own messages
      if speaker == @config['hipchat']['name'] and sudo.nil?
        nil

      else
        bot.plugins.each do |plugin|
          begin
            response = plugin.receive_message(message, speaker)
            unless response.nil?
              if response.respond_to?('each')
                response.each do |line|
                  self.speak line
                end
              else
                self.speak response
              end
            end
          rescue => e
            self.speak "ERROR: Plugin #{plugin.class.name} just crashed"
            self.speak "Message: #{e.message}"
          end
        end
      end
    end

    @muc.on_private_message do |time, speaker, message|
      nil
    end

    @muc.on_room_message do |time, message|
      nil
    end
  end

  def join
    @muc.join(@config['hipchat']['room'] + '/' + @config['hipchat']['name'])
    self.speak @config['bot']['hello']
  end

  def speak(message)
    @muc.send Jabber::Message.new(@muc.room, message)
  end

  def still_connected?
    @client.is_connected?
  end
end
