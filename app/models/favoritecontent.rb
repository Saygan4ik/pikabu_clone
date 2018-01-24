# frozen_string_literal: true

class Favoritecontent < ApplicationRecord
  belongs_to :user
  belongs_to :favorite, optional: true
  belongs_to :content, polymorphic: true, class_name: 'Favoritecontent'
end
