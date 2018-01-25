class TopCommentSerializer < ActiveModel::Serializer
  attributes :date, :rating
  belongs_to :comment
end
