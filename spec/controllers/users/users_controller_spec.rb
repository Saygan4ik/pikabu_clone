# frozen_string_literal:true

require 'rails_helper'

describe Api::V1::Users::UsersController do
  context 'when action show' do
    context 'and user not found' do
      let(:response) { get :show, params: { id: 1 } }
      it 'return 404' do
        expect(response).to be_not_found
      end
    end

    context 'and user exists' do
      let!(:user) { create(:user) }
      let!(:post1) { create(:post, user_id: user.id) }
      let!(:post2) { create(:post, user_id: user.id) }
      let(:response) { get :show, params: { id: user.id } }
      it 'receive user with posts' do
        expect(json_response)
          .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                              .new(user.reload).to_json))
      end
    end
  end

  context 'when action ban' do
    let(:response) { post :ban_user, params: { user_id: 1 } }
    context 'and user unauthorized' do
      it 'return unauthorized' do
        expect(response).to be_unauthorized
      end
    end

    context 'and user authorized' do
      let!(:user1) { create(:user, token: 'token') }
      headers = { 'X-USER-TOKEN' => 'token' }
      before(:each) do
        request.headers.merge! headers
      end
      context 'and not admin' do
        it 'return forbidden' do
          expect(response).to be_forbidden
        end
      end
      context 'and user admin' do
        before(:each) do
          user1.role = 1
          user1.save
        end
        context 'and banned user not found' do
          it 'return not found' do
            expect(response).to be_not_found
          end
        end

        context 'and banned user exists' do
          let!(:user2) { create(:user) }
          let(:response) { post :ban_user, params: { user_id: user2.id, ban_time: 100 } }
          it 'return 200' do
            expect(response).to be_success
          end

          it 'receive message - User banned' do
            expect(json_response['messages']).to eq('User banned')
          end

          it 'banned user is set to a isBanned' do
            expect { response }.to change { user2.reload.isBanned }.from(false).to(true)
          end

          it 'banned user is set to a timeout' do
            expect { response }.to change { user2.reload.timeoutBan }
          end

          context 'and get incorrect ban_time' do
            let(:response) { post :ban_user, params: { user_id: user2.id, ban_time: '100a' } }
            it 'return bad request' do
              expect(response).to be_bad_request
            end
          end
        end
      end
    end
  end
end
