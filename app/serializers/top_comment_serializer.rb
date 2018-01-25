# frozen_string_literal: true

class TopCommentSerializer < ActiveModel::Serializer
  attributes :date, :rating
  belongs_to :comment
end
