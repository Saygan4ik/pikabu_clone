class User < ApplicationRecord
  has_secure_password
  validates :nickname, :email, presence: true
  validates :nickname, :email, uniqueness: true
  validates_length_of :password, in: 6..72, allow_blank: true
  validates_presence_of :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates :token, uniqueness: true, allow_nil: true
  validates :email, format: { with: /\A[^@\s]+@[^@\s]+\z/ }

  protected

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
end
