require 'rails_helper'

RSpec.describe Invite, type: :model do
  context 'attributes' do
    # NOTE: if it saves successfully we should assume it was sent
    # it { should respond_to(:sent) }
    it { should respond_to(:received) }
    it { should respond_to(:accepted) }
    it { should respond_to(:rejected) }
  end

  context 'unique indexes' do
    it { should have_db_index(:user_id) }
    it { should have_db_index(:game_id) }
    it { should have_db_index([:user_id, :game_id]).unique(true) }
  end

  context 'relationships' do
    it { should belong_to(:user) }
    it { should belong_to(:game) }
  end

  context 'validations' do

  end

  context 'on create' do
    # it 'should have \'sent\' set to false' do
    #   @invite = create(:invite, sent: nil)
    #
    #   expect(Invite.find(@invite.id).sent?).to be false
    # end

    it 'should have \'received\' set to false' do
      @invite = create(:invite, received: nil)

      expect(Invite.find(@invite.id).received?).to be false
    end

    it 'should have \'accepted\' set to false' do
      @invite = create(:invite, accepted: nil)

      expect(Invite.find(@invite.id).accepted?).to be false
    end

    it 'should have \'rejected\' set to false' do
      @invite = create(:invite, rejected: nil)

      expect(Invite.find(@invite.id).rejected?).to be false
    end
  end
end
