class Post < ApplicationRecord
  acts_as_votable
  mount_uploaders :files, PostFilesUploader
  validates :title, presence: true
  belongs_to :user, counter_cache: true
  belongs_to :community, optional: true
  has_and_belongs_to_many :tags
  has_many :comments
end
