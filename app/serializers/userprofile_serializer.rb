# frozen_string_literal: true

require_dependency 'app/services/post_finder'

class UserprofileSerializer < ActiveModel::Serializer
  attributes :userprofile
end
