# frozen_string_literal: true

class TagSerializer < ActiveModel::Serializer
  attributes :name
  belongs_to :post
end
