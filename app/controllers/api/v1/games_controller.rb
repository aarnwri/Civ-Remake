class Api::V1::GamesController < Api::V1::ApplicationController

  def create
    @game = Game.create(creator_id: current_user.id)

    if @game
      @players = @game.players

      render :show, status: :created
    else
      render json: {
        errors: @game.errors.full_messages
      }.to_json, status: :unprocessable_entity
    end
  end

  def index
    @games = (current_user.created_games + current_user.games).uniq

    render :index, status: :ok
  end
end