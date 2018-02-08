# frozen_string_literal:true

require 'rails_helper'

describe Api::V1::Users::SessionsController do
  context 'when action login' do
    let!(:user) { create(:user, email: 'user@example.com', password: 'password') }
    context 'and getting incorrect email or password' do
      let(:response) { post :login, params: { email: 'incorrect_email', password: 'incorrect_password' } }
      it 'return 422' do
        expect(response.status).to eq(422)
      end
    end

    context 'and getting correct email and password' do
      let(:response) { post :login, params: { email: 'user@example.com', password: 'password' } }
      it 'return 200' do
        expect(response).to be_success
      end
      it 'receive user token' do
        expect(json_response).to include 'X-USER-TOKEN'
      end
    end
  end

  context 'when action logout' do
    context 'and user unauthorized' do
      let(:response) { delete :logout }
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
      let(:response) { delete :logout }
      it 'return 200' do
        expect(response).to be_success
      end

      it 'return message - Logout successfully' do
        expect(json_response['messages']).to eq('Logout successfully')
      end

      it 'user token set to nil' do
        expect{ response }.to change{ user.reload.token }.from('token').to(nil)
      end
    end
  end
end
