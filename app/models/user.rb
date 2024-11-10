require 'digest'

class User < ApplicationRecord
  enum :role, { admin: 0, buyer: 1, seller: 2, rider: 3 }

  phony_normalize :phone, default_country_code: 'BD'
  has_many :products, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_one :cart, dependent: :destroy

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :password, presence: true, length: { minimum: 6 }

  validates :role, presence: true, inclusion: { in: roles.keys, message: '%{value} is not a valid role' }
  validates :phone, phony_plausible: true, presence: true

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
