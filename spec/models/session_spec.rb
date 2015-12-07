require 'rails_helper'

require 'models/shared_contexts/attributes'

RSpec.describe Session, type: :model do

  context 'modules' do
    it('should include Tokenable') { expect(create(:user).session.class.ancestors).to include(Tokenable) }
  end

  context 'attributes' do
    it { should respond_to(:token) }
  end

  context 'unique indexes' do
    it { should have_db_index(:user_id).unique(true) }
    it { should have_db_index(:token).unique(true) }
  end

  context 'relationships' do
    it { should belong_to(:user) }
  end

  context 'validations' do
    it { should validate_presence_of(:user_id) }

    # TODO: fix this validation test... somehow it doesn't work with how sessions get created now?...
    # it { should validate_uniqueness_of(:token).allow_nil }
    it { should validate_uniqueness_of(:user_id) }

    # TODO: either write a custom validation for this or fix shoulda-matchers...
    # it { should validate_numericality_of(:user_id).only_integer.is_greater_than(0) }
  end

  context 'methods' do
    # let(:session) { create(:user).session }
    # @session = User.create(email: "test@test.com", password: "password")

    context '#create_token' do
      # include_context 'attribute_changed', @session, :token, :create_token

      it 'should fix this'
    end

    context '#update_token' do
      # include_context 'attribute_changed', @session, :token, :update_token

      it 'should fix this'
    end

    context '#destroy_token' do
      # include_context 'attribute_changed', @session, :token, :destroy_token, [], { desired_val: nil }

      it 'should fix this'
    end
  end
end
