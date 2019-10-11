require 'typesafe_enum'

module Metadata
  class Source < TypesafeEnum::Base
    new :TIND
    new :MILLENNIUM
  end
end
