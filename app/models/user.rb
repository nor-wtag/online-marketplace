class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { admin: 0, buyer: 1, seller: 2, rider: 3 }

  phony_normalize :phone, default_country_code: 'BD'

  has_many :products, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_one :cart, dependent: :destroy

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, phony_plausible: true, presence: true
  # validates :password, presence: true, length: { minimum: 6 }, confirmation: true, allow_blank: true
  
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
