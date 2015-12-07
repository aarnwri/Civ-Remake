class Session < ActiveRecord::Base
  include Tokenable

  after_create :create_token

  belongs_to :user

  validates :user_id, {
    presence: true,
    uniqueness: true,
    numericality: { only_integer: true, greater_than: 0 }
  }

  validates :token, {
    uniqueness: true,
    allow_nil: true
  }

  def create_token
    self.set_token(:token)
    self.save
  end

  def update_token
    self.create_token
  end

  def destroy_token
    self.nullify_token(:token)
    self.save
  end
end
