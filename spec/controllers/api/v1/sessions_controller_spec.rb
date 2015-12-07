require 'rails_helper'

require 'spec_helpers/requests'
require 'spec_helpers/headers'
require 'controllers/api/v1/shared_contexts/authentication'
require 'controllers/api/v1/shared_contexts/requests'

RSpec.describe Api::V1::SessionsController, type: :controller do
  render_views

  context 'POST #create' do
    let(:user) { create(:user) }
    let!(:session) { user.session }
    let(:credentials) { { email: user.email, password: "factory_foo!"} }

    context 'with valid credentials' do
      context 'sent via json' do
        include_context "removed_auth_header"
        before(:each) do
          json_params = { session: credentials }
          @initial_session_count = Session.all.count
          post :create, json_params
        end

        include_context 'expect_json_error_message', 'authorization header is missing'
        include_context 'expect_same_db_count', :session
        include_context 'expect_status_code', 422
      end

      context 'sent via headers' do
        before(:each) { set_headers({ basic: credentials }) }

        context 'where the existing token not nil' do
          before(:each) do
            @original_token = session.token
            @initial_session_count = Session.all.count
            post :create
          end

          it 'should regenrate the token' do
            expect(User.find(user.id).session.token).to_not eq(@original_token)
          end

          include_context 'expect_valid_json', {
            data: { id: Fixnum, type: 'session',
              attributes: {
                token: String
              },
              relationships: {
                user: {
                  data: { id: Fixnum, type: 'user' }
                }
              }
            },
            included: [ {
              id: Fixnum,
              type: 'user',
              attributes: {
                email: String,
              }
            } ]
          }
          include_context 'expect_same_db_count', :session
          include_context 'expect_status_code', 201
        end

        context 'where the existing token is not nil' do
          before(:each) do
            session.destroy_token
            @original_token = Session.find(session.id).token
            @initial_session_count = Session.all.count
            post :create
          end

          it 'should regenerate the token and shouldnt be nil' do
            expect(User.find(user.id).session.token).to_not be_nil
            expect(User.find(user.id).session.token).to_not eq(@original_token)
          end

          include_context 'expect_valid_json', {
            data: { id: Fixnum, type: 'session',
              attributes: {
                token: String
              },
              relationships: {
                user: {
                  data: { id: Fixnum, type: 'user' }
                }
              }
            },
            included: [ {
              id: Fixnum,
              type: 'user',
              attributes: {
                email: String,
              }
            } ]
          }
          include_context 'expect_same_db_count', :session
          include_context 'expect_status_code', 201
        end
      end
    end

    context 'with invalid credentials' do
      context 'because it is a token' do
        include_context 'token_authenticated_user'

        before(:each) do
          @initial_session_count = Session.all.count
          post :create
        end

        include_context 'expect_same_db_count', :session
        include_context 'expect_status_code', 401
        include_context 'expect_json_error_message', 'invalid email or password'
      end

      invalid_creds = [
        { email: 'invalid@invalid.com',
          reason: "can't be found"
        },
        { password: 'changeme',
          reason: "is wrong"
        },
        { email: 'malformed',
          reason: "is incorrectly formatted"
        },
        { password: '2short',
          reason: "is incorrectly formatted"
        },
      ]

      invalid_creds.each do |hash|
        context "because #{hash.keys.first.to_s} #{hash[:reason]}" do
          before(:each) do
            @initial_session_count = Session.all.count

            invalid_param_hash = { hash.keys.first => hash.values.first }
            set_headers({ basic: credentials.merge(invalid_param_hash) })
            post :create
          end

          include_context 'expect_same_db_count', :session
          include_context 'expect_status_code', 401
          include_context 'expect_json_error_message', 'invalid email or password'
        end
      end
    end
  end

  context 'DELETE #destroy' do
    let(:user) { create(:user) }
    let!(:session) { user.session }

    context 'with invalid token' do
      context 'because it was sent via json' do
        include_context "removed_auth_header"

        before(:each) do
          @params = { session: { token: session.token, id: session.id } }.to_json
          @initial_session_count = Session.all.count
          delete :destroy, @params, id: session.id
        end

        include_context 'expect_same_db_count', :session
        include_context 'expect_same_db_attrs', :session
        include_context 'expect_json_error_message', 'token authentication failed'
        include_context 'expect_status_code', 401
      end

      context 'because it does not exist' do
        before(:each) do
          set_headers(token: "invalid")
          @initial_session_count = Session.all.count
          delete :destroy, id: session.id
        end

        include_context 'expect_same_db_count', :session
        include_context 'expect_same_db_attrs', :session
        include_context 'expect_json_error_message', 'token authentication failed'
        include_context 'expect_status_code', 401
      end
    end

    context 'with valid token' do
      before(:each) { set_headers(token: session.token) }

      context 'and valid id' do
        before(:each) do
          @initial_session_count = Session.all.count
          delete :destroy, id: session.id
        end

        it 'should set the token to nil' do
          expect(Session.find(session.id).token).to be_nil
        end
        include_context 'expect_same_db_count', :session
        include_context 'expect_status_code', 204
        it 'should not return any json (no body)' do
          expect(response.body).to be_empty
        end
      end

      context 'and invalid id' do
        context 'because it belongs to another user' do
          before(:each) do
            @session2 = create(:user).session
            @initial_session_count = Session.all.count
            delete :destroy, id: @session2.id
          end

          include_context 'expect_same_db_count', :session
          include_context 'expect_same_db_attrs', :session
          include_context 'expect_status_code', 403
          include_context 'expect_json_error_message', 'cannot logout another user'
        end

        context 'because it does not exist' do
          before(:each) do
            @initial_session_count = Session.all.count
            delete :destroy, id: 1000
          end

          include_context 'expect_same_db_count', :session
          include_context 'expect_same_db_attrs', :session
          include_context 'expect_status_code', 422
          include_context 'expect_json_error_message', 'session not found'
        end
      end
    end
  end

  context 'GET #show' do
    let(:user) { create(:user) }
    let!(:session) { user.session }

    context 'with invalid token' do
      context 'because it does not exist' do
        before(:each) do
          set_headers(token: "invalid")
          @initial_session_count = Session.all.count
          get :show, id: session.id
        end

        include_context 'expect_same_db_count', :session
        include_context 'expect_same_db_attrs', :session
        include_context 'expect_json_error_message', 'token authentication failed'
        include_context 'expect_status_code', 401
      end
    end

    context 'with valid token' do
      before(:each) { set_headers(token: session.token) }

      context 'and valid id' do
        before(:each) do
          @initial_session_count = Session.all.count
          get :show, id: session.id
        end

        include_context 'expect_same_db_count', :session
        include_context 'expect_status_code', 200
        include_context 'expect_valid_json', {
          data: { id: Fixnum, type: 'session',
            attributes: {
              token: String
            },
            relationships: {
              user: {
                data: { id: Fixnum, type: 'user' }
              }
            }
          },
          included: [ {
            id: Fixnum,
            type: 'user',
            attributes: {
              email: String,
            }
          } ]
        }
      end

      context 'and invalid id' do
        context 'because it belongs to another user' do
          before(:each) do
            @session2 = create(:user).session
            @initial_session_count = Session.all.count
            get :show, id: @session2.id
          end

          include_context 'expect_same_db_count', :session
          include_context 'expect_same_db_attrs', :session
          include_context 'expect_status_code', 403
          include_context 'expect_json_error_message', 'cannot fetch another user session'
        end

        context 'because it does not exist' do
          before(:each) do
            @initial_session_count = Session.all.count
            get :show, id: 1000
          end

          include_context 'expect_same_db_count', :session
          include_context 'expect_same_db_attrs', :session
          include_context 'expect_status_code', 422
          include_context 'expect_json_error_message', 'session not found'
        end
      end
    end
  end
end
