class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  enum :role, { admin: 0, buyer: 1, seller: 2, rider: 3 }

  has_many :products, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_one :cart, dependent: :destroy

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :phone, presence: true
  validates :phone, format: {
    with: /\A(017|013|018|019|015)\d{8}\z/,
    message: 'must start with 0 and contain exactly 11 digits'
  }

  validates :password, presence: true, length: { minimum: 6 }, confirmation: true, allow_blank: true
  validates :role, presence: true, inclusion: { in: roles.keys, message: '%{value} is not a valid role' }

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
