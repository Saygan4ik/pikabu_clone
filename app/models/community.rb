# frozen_string_literal: true

class Community < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_and_belongs_to_many :users
  has_many :posts
end
