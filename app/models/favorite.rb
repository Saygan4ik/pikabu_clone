# frozen_string_literal: true

class Favorite < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
