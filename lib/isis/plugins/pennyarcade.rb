require 'isis/plugins/base'
require 'nokogiri'
require 'open-uri'

class Isis::Plugin::PennyArcade < Isis::Plugin::Base

  def respond_to_msg?(msg, speaker)
    msg.downcase == "!pa"
  end

  def response
    comic
  end

  def comic
    page = Nokogiri::HTML(open('http://www.penny-arcade.com/comic/'))
    image = page.css('.comic > img').first
    [image['src'], image['alt']]
  end
end
