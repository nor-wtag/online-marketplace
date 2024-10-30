require 'digest'

class User < ApplicationRecord

  enum :role, { admin: 0, buyer: 1, seller: 2, rider: 3 }


  has_many :products
  has_many :reviews
  has_one :cart

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :phone, presence: true
  validates :phone, format: {
    with: /\A(017|013|018|019|015)\d{8}\z/,
    message: 'must start with 0 and contain exactly 11 digits'
  }

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
