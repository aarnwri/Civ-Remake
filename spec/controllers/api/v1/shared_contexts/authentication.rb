require 'spec_helpers/headers'

RSpec.shared_context 'token_authenticated_user' do
  let(:user) { create(:user) }
  let(:session) { user.session }

  before(:each) { set_headers({ token: session.token }) }
end

RSpec.shared_context 'removed_auth_header' do
  before(:each) { remove_auth_header }
end
