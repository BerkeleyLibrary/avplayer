require 'typesafe_enum'

class Restrictions < TypesafeEnum::Base
  new :PUBLIC
  new :UCB_IP

  def inspect
    "#{self.class}::#{key}"
  end

end
