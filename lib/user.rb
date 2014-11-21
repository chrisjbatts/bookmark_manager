require 'bcrypt'

class User

  include DataMapper::Resource

  validates_confirmation_of :password

  attr_reader :password
  attr_writer :password_confirmation

  property :id,                 Serial
  property :email,              String
  property :password_digest,    Text

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

end