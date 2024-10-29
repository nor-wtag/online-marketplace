require 'digest'

class User < ApplicationRecord
  # has_secure_password

  enum role: { admin: 0, buyer: 1, seller: 2, rider: 3 }

  has_many :products
  has_many :reviews
  has_one :cart

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: 'must be a valid email address' }
  validates :phone, presence: true, numericality: { only_integer: true }
  validates :password, presence: true, length: { minimum: 6 }
  validates :role, presence: true, inclusion: { in: roles.keys, message: '%{value} is not a valid role' }

  before_save :hash_password

  def hash_password
    self.password = Digest::SHA256.hexdigest(password) if password.present?
  end

  def authenticate_the_login(plain_password)
    Digest::SHA256.hexdigest(plain_password) == password
  end

  def admin?
    role == 'admin'
  end

  def buyer?
    role == 'buyer'
  end

  def seller?
    role == 'seller'
  end

  def rider?
    role == 'rider'
  end
end
