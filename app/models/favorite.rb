# frozen_string_literal: true

class Favorite < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :users, through: :favoritecontents
  has_many :favoritecontents
end
