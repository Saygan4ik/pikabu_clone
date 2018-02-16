module Exceptions
  class Unauthorized < StandardError; end
  class BadRequest < StandardError; end
  class Forbidden < StandardError; end
end
