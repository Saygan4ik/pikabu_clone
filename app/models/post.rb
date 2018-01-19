class Post < ApplicationRecord
  validates :title, presence: true
  belongs_to :user, counter_cache: true
  belongs_to :community
  has_and_belongs_to_many :tags
  has_many :comments
end
