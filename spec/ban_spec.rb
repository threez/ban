require 'spec_helper'

describe Ban do
  it 'should have a version number' do
    Ban::VERSION.should_not be_nil
  end
  
  let(:low_str) { '21588|24|322|1' }
  let(:low_str7bit) do
    [
      50, 0, 49,  0, 53, 0, 56, 0, 56, 0, 124, 0, 50, 0,
      52, 0, 124, 0, 51, 0, 50, 0, 50, 0, 124, 0, 49, 0
    ]
  end
  let(:high_str) { "\xFD" }
  let(:high_str7bit) do
    [
      125, 1
    ]
  end
  
  context '.decode' do
    it 'should decode low' do
      described_class.decode7bit(low_str7bit).should == low_str
    end
    
    it 'should decode high' do
      described_class.decode7bit(high_str7bit).should == high_str
    end
  end
  
  context '.encode' do
    it 'should encode low' do
      described_class.encode7bit(low_str).should == low_str7bit
    end

    it 'should encode high' do
      described_class.encode7bit(high_str).should == high_str7bit
    end
  end
end
