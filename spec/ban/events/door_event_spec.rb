require 'spec_helper'

describe Ban::DoorEvent do
  context 'open' do
    let(:data) { [79, 0, 80, 0, 69, 0, 78, 0] }

    subject {  described_class.parse(data) }

    its(:name) { should == 'door-opened' }
    its(:valid?) { should == true }
    its(:to_hash) { should == { "state" => "open" } }
    its(:to_s) { should == "door: opened" }
  end

  context 'close' do
    let(:data) { [67, 0, 76, 0, 79, 0, 83, 0, 69, 0] }

    subject {  described_class.parse(data) }

    its(:name) { should == 'door-closed' }
    its(:valid?) { should == true }
    its(:to_hash) { should == { "state" => "close" } }
    its(:to_s) { should == "door: closed" }
  end
end
