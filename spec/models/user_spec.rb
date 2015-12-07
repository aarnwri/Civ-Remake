require 'rails_helper'

RSpec.describe User, :type => :model do

  context 'attributes' do
    it { should respond_to(:email) }
    it { should respond_to(:password_digest) }
  end

  context 'authentication' do
    # these methods are part of have_secure_password
    it { should respond_to(:password) }
    it { should respond_to(:authenticate) }

    it { should have_secure_password }
  end

  context 'unique indexes' do
    it { should have_db_index(:email).unique(true) }
  end

  context 'relationships' do
    it { should have_one(:session) }
    it { should have_many(:players) }
    it { should have_many(:games).through(:players) }
    it { should have_many(:created_games) }

    context 'when destroyed' do
      it 'should destroy its session' do
        @user = create(:user)
        @session = @user.session

        @user.destroy
        expect { Session.find(@session.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      # NOTE: I don't think we should delete players in case any game data is tied to the players.
      # The game should be able to continue after a player has left the game.
      it 'should archive its players'
    end
  end

  context 'validations' do
    it { should validate_presence_of(:email) }

    it { should validate_length_of(:email).is_at_most(50) }
    it { should validate_length_of(:password).is_at_least(8) }

    it { should validate_uniqueness_of(:email).case_insensitive }

    context 'email string' do
      it 'should be stored as lower case' do
        @user = create(:user, email: "aAbBcC@lEtTeRs.CoM")
        expect(User.find(@user.id).email).to eq("aabbcc@letters.com")
      end

      context 'with invalid email format' do
        it 'should not be valid' do
          addresses = %w[user@foo,com user_at_foo.org example.user@foo.
            foo@bar_baz.com foo@bar+baz.com foo@bar..com
          ]

          addresses.each do |invalid_address|
            @user = build(:user, email: invalid_address)
            expect(@user).to_not be_valid
          end
        end
      end

      context 'with valid email format' do
        it 'should be valid' do
          addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]

          addresses.each do |valid_address|
            @user = build(:user, email: valid_address)
            expect(@user).to be_valid
          end
        end
      end
    end
  end

  context 'methods' do
    context '#password' do
      it 'should not return the password unless hashed' do
        @user = create(:user, password: "password")
        expect(User.find(@user.id).password).to_not eq("password")
      end
    end

    context '#authenticate' do
      before(:each) do
        @user = create(:user, password: "password")
        @db_user = User.find(@user.id)
      end

      context 'with valid password' do
        it 'should return the user' do
          expect(@db_user.authenticate('password')).to eq(@db_user)
        end
      end

      context 'with invalid password' do
        it 'should return false' do
          expect(@db_user.authenticate("false_password")).to eq(false)
        end
      end
    end # end context #authenticate
  end # end context methods
end
