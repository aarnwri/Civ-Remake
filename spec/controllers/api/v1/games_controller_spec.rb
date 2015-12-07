require 'rails_helper'

require 'spec_helpers/requests'
require 'spec_helpers/headers'

require 'controllers/api/v1/shared_contexts/requests'

RSpec.describe Api::V1::GamesController, type: :controller do
  render_views

  context 'POST #create' do
    let(:user) { create(:user) }
    let(:session) { user.session }
    let(:game_attrs) { attributes_for(:game) }
    # let(:valid_game_json) do
    #   return {
    #     data: {
    #       attributes: {
    #         # name: game_attrs[:name]
    #       }
    #     }
    #   }
    # end

    context 'with valid token' do
      before(:each) { set_headers(token: session.token) }

      context 'with valid params' do
        before(:each) do
          @initial_game_count = Game.all.count
          @initial_player_count = Player.all.count
          @initial_games = Game.all.to_a
          @initial_players = Player.all.to_a
          post :create
        end

        include_context 'expect_plus_one_db_count', :game, :player
        include_context 'expect_status_code', 201
        it 'should have the new player belonging to the user' do
          new_player = (Player.all.to_a - @initial_players).first
          expect(new_player.user).to eq(user)
        end
        it 'should have the new player belonging to the game' do
          new_player = (Player.all.to_a - @initial_players).first
          new_game = (Game.all.to_a - @initial_games).first
          expect(new_player.game).to eq(new_game)
        end
        it 'should belong to the current user' do
          new_game = (Game.all.to_a - @initial_games).first
          expect(new_game.creator).to eq(user)
        end
        include_context 'expect_valid_json', {
          data: { id: Fixnum, type: 'game',
            attributes: {
              name: String,
              started: false,
            },
            relationships: {
              players: {
                data: [
                  { id: Fixnum, type: 'player' }
                ]
              },
              creator: {
                data: { id: Fixnum, type: 'user' }
              }
            }
          },
          included: [ {
            id: Fixnum,
            type: 'player',
            attributes: {
              user_id: Fixnum,
              game_id: Fixnum
            }
          } ]
        }
      end

      # invalid_attributes = [
      #   { name: "x" * 51,
      #     reason: "is too long",
      #     error: "Name is too long (maximum is 50 characters)"
      #   }
      # ]
      #
      # invalid_attributes.each do |hash|
      #   context "because #{hash.keys.first.to_s} #{hash[:reason]}" do
      #     before(:each) do
      #       @initial_game_count = Game.all.count
      #       @initial_player_count = Player.all.count
      #       @initial_games = Game.all.to_a
      #       @initial_players = Player.all.to_a
      #
      #       invalid_param_hash = { hash.keys.first => hash.values.first }
      #       invalid_json = { data: { attributes: invalid_param_hash } }
      #
      #       post :create, valid_game_json.deep_merge(invalid_json)
      #     end
      #
      #     include_context 'expect_same_db_count', :game, :player
      #     include_context 'expect_status_code', 422
      #     include_context 'expect_json_error_message', "#{hash[:error]}"
      #   end
      # end
    end

    context 'with invalid token' do
      before(:each) do
        set_headers(token: "gibberish")
        @initial_game_count = Game.all.count
        @initial_player_count = Player.all.count
        @initial_games = Game.all.to_a
        @initial_players = Player.all.to_a
        post :create
      end

      include_context 'expect_same_db_count', :game, :player
      include_context 'expect_json_error_message', 'token authentication failed'
      include_context 'expect_status_code', 401
    end
  end

  context 'GET #index' do
    let(:user) { create(:user) }
    let(:session) { user.session }

    context 'with valid token' do
      before(:each) do
        set_headers(token: session.token)
        3.times { create(:game, creator: user) }
        get :index
      end

      include_context 'expect_status_code', 200
      include_context 'expect_valid_json', {
        data: [
          {
            type: 'game',
            id: Fixnum,
            attributes: {
              name: String
            }
          }, {
            type: 'game',
            id: Fixnum,
            attributes: {
              name: String
            }
          }, {
            type: 'game',
            id: Fixnum,
            attributes: {
              name: String
            }
          }
        ]
      }
    end

    context 'with invalid token' do
      # NOTE: we're not going to need valid params here... I don't think we need to
      # test valid filter strings here either...

      before(:each) do
        set_headers(token: "gibberish")
        get :index
      end

      include_context 'expect_json_error_message', 'token authentication failed'
      include_context 'expect_status_code', 401
    end
  end
end
