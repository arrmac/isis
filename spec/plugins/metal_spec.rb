# encoding: utf-8
require 'spec_helper'

describe Isis::Plugin::Metal do
  let(:speaker) { Random.speaker }
  triggers = [
    'metal',
    '-metal-',
    "!metal",
  ]

  it "ignores most things" do
    subject.receive_message( Random.message, speaker ).should not_respond
  end

  triggers.each do |keyword|
    it "responds to #{keyword}" do
      subject.receive_message( keyword, speaker ).should respond_with_a_message
    end
  end

end
