require 'spec_helper'

describe Ban::RcEvent do
  subject { described_class.parse(data) }
  
  context 'valid' do
    let(:data) do
      [
        50, 0, 49,  0, 53, 0, 56, 0, 56, 0, 124, 0, 50, 0,
        52, 0, 124, 0, 51, 0, 50, 0, 50, 0, 124, 0, 49, 0
      ]
    end
    
    its(:name) { should == 'rc-turned-off' }
    its(:valid?) { should == true }
    its(:to_hash) do
      should == {
        "decimal" => 21588,
        "bits" => 24,
        "binary" => "000000000101010001010100",
        "tristate" => "0000FFF0FFF0",
        "delay" => 322,
        "protocol" => 1
      }
    end
    its(:to_s) do
      should == "decimal: 21588 (24 bits) binary 000000000101010001010100 " + 
                "tri-state: 0000FFF0FFF0 pulse length: 322 (ms) protocol: 1"
    end
  end
  
  context 'invalid' do
    let(:data) do
      [
        50, 0, 49,  0, 53, 0, 56, 0, 30, 0, 124, 0, 50, 0,
        52, 0, 124, 0, 51, 0, 50, 0, 50, 0, 124, 0, 49, 0
      ]
    end
  
    its(:valid?) { should == false }
  end
end