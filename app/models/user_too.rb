include Mailboxer::Models::Messageable

class UserToo < ActiveRecord::Base
  # set this up as a messageable object
  acts_as_messageable
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :email

  #method needed for messaging
  def name
    read_attribute :login    
  end

  #method needed for messaging
  def mailboxer_email
    return nil  
  end
end
