require 'rails_helper'

RSpec.describe Game, type: :model do
  context 'attributes' do
    it { should respond_to(:name) }
    it { should respond_to(:started) }
  end

  context 'relationships' do
    it { should belong_to(:creator).class_name('User') }
    it { should have_many(:players) }
    it { should have_many(:playing_users).through(:players).class_name('User') }
    it { should have_many(:invites) }
    it { should have_many(:invited_users).through(:invites).class_name('User') }
  end

  context 'validations' do
    it { should validate_presence_of(:creator_id) }
    it { should_not validate_presence_of(:name) }

    it { should validate_length_of(:name).is_at_most(50) }
  end

  context 'on create' do
    before(:each) { @game = create(:game) }

    it 'should call generate_name' do
      expect(Game.find(@game.id).name).to_not be_empty
    end

    it 'should have \'started\' set to false' do
      @game = create(:game, started: nil)

      expect(Game.find(@game.id).started?).to be false
    end

    it 'should add the creator to the newly generated game' do
      expect(Player.find_by(user_id: @game.creator.id, game_id: @game.id)).to_not be_nil
    end
  end

  context 'methods' do
    context 'generate_name' do
      it 'add some examples here'
    end

    context 'add_creator_as_player' do
      it 'add some examples here'
    end
  end
end
