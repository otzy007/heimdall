class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, :omniauth_providers => [:facebook]

  has_many :my_categories
  has_many :event_filters
  has_many :keywords

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first

    unless user
      user = User.create(
          provider:auth.provider,
           uid:auth.uid,
           email:auth.info.email,
           password:Devise.friendly_token[0,20]
      )
    end
    user.token = auth.credentials.token
    user.save

    user
  end
end
