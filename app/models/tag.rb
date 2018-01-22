# frozen_string_literal: true

class Tag < ApplicationRecord
  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
  has_and_belongs_to_many :posts
end
