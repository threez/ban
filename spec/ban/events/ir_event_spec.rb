require 'spec_helper'

describe Ban::IrEvent do
  let(:data) { [51, 0, 48, 0, 54, 0, 56, 0, 57, 0] }

  subject {  described_class.parse(data) }

  its(:name) { should == 'ir-received' }
  its(:valid?) { should == true }
  its(:to_hash) do
    should == { "code" => 30689, "hex" => "77e1" }
  end
  its(:to_s) do
    should == "30689 (0x77e1)"
  end
end
