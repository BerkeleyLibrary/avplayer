require 'typesafe_enum'

module Tind
  class Restrictions < TypesafeEnum::Base
    new :PUBLIC
    new :UCB_IP
  end
end
