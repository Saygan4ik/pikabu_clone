# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  acts_as_voter
  validates :nickname, :email, presence: true
  validates :nickname, :email, uniqueness: true
  validates_length_of :password, in: 6..72, allow_blank: true
  validates_presence_of :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates :token, uniqueness: true, allow_nil: true
  validates :email, format: { with: /\A[^@\s]+@[^@\s]+\z/ }
  enum role: %i[user admin]
  has_and_belongs_to_many :communities
  has_many :posts
  has_many :comments
  has_many :favoritecontents
  has_many :favorites, through: :favoritecontents

  protected

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
end
