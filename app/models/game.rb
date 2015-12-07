class Game < ActiveRecord::Base

  before_create :generate_name
  before_create :set_started_to_false
  after_create :add_creator_as_player

  belongs_to :creator, class_name: "User"
  has_many :players
  has_many :playing_users, through: :players, class_name: "User"
  has_many :invites
  has_many :invited_users, through: :invites, class_name: "User"

  validates :creator_id, {
    presence: true
  }

  validates :name, {
    length: { maximum: 50, message: "is too long (maximum is 50 characters)" }
  }

  private

    def generate_name
      player_game_names = self.creator.games.map { |game| game.name }
      creator_game_names = self.creator.created_games.map { |game| game.name }
      current_names = player_game_names + creator_game_names

      new_game_names = current_names.select { |name| name.match(/^new_game_[0-9]*$/) if name }
      highest_int = new_game_names.map { |name| name.split("new_game_").last.to_i }.max

      next_int_str = highest_int ? highest_int + 1 : "1"
      self.name = "new_game_#{next_int_str}"
    end

    def set_started_to_false
      self.started = false

      # NOTE: need to return true here or else rails will think the callback failed
      return true
    end

    def add_creator_as_player
      Player.create(user_id: self.creator.id, game_id: self.id)
    end
end
