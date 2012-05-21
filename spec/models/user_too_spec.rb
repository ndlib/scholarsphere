require 'spec_helper'

describe UserToo do
  before do
    @u1 = User.new(:login=>'u1')
    @u2 = User.new(:login=>'u2')
  end
  after do
    @u1.delete
    @u2.delete
  end
  
  it ' should send message' do
     recipt = u1.send_message(u2, "log", "Audit Run")
     recipt.should_not be_empty  
  end
end
