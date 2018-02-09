# frozen_string_literal:true

require 'rails_helper'

describe Api::V1::Users::RegistrationsController do
  context 'when action register' do
    let(:response) { post :register, params: { user: { nickname: 'nickname',
                                               email: 'email@example.com',
                                               password: 'password',
                                               password_confirmation: 'password' } } }
    it 'return 200' do
      expect(response).to be_success
    end

    it 'increased quantity users' do
      expect { response }.to change { User.count }.by(1)
    end
  end

  context 'when action update' do
    context 'and user unauthorized' do
      let(:response) { patch :update }
      it 'return unauthorized' do
        expect(response).to be_unauthorized
      end
    end

    context 'and user authorized' do
      let!(:user) { create(:user, token: 'token') }
      headers = { 'X-USER-TOKEN' => 'token' }
      before(:each) do
        request.headers.merge! headers
      end
      context 'and getting incorrect old password' do
        let(:response) { patch :update, params: { old_password: 'incorrect_password' } }
        it 'return message - Password is not valid' do
          expect(json_response['messages']).to eq('Password is not valid')
        end
      end

      context 'and getting correct old password' do
        let(:response) { patch :update, params: { old_password: 'password',
                                                 password: 'new_password',
                                                 password_confirmation: 'new_password' } }
        it 'return 200' do
          expect(response).to be_success
        end

        it 'changed password' do
          expect { response }.to(change { user.reload.password_digest })
        end
      end
    end
  end
end
