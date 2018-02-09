# frozen_string_literal:true

require 'rails_helper'

describe Api::V1::FavoritecontentsController do
  context 'when action add_to_favorites' do
    context 'and user unauthorized' do
      it 'return unauthorized' do
        post :add_to_favorites
        expect(response).to be_unauthorized
      end
    end

    context 'and user authorized' do
      let!(:user) { create(:user, token: 'token') }
      headers = { 'X-USER-TOKEN' => 'token' }
      before(:each) do
        request.headers.merge! headers
      end
      context 'and post or comment not found' do
        let(:response) { post :add_to_favorites, params: { post_id: 1 } }
        it 'return not_found' do
          expect(response).to be_not_found
        end
      end

      context 'and post or comment exists' do
        let!(:post1) { create(:post) }
        let(:response) { post :add_to_favorites, params: { post_id: post1.id } }
        context 'and has not been added previously' do
          it 'return message - Added to favorites' do
            expect(json_response['messages']).to eq('Added to favorites')
          end

          it 'increased contents count' do
            expect { response }.to change { user.favoritecontents.count }.by(1)
          end
        end

        context 'add has been added previously' do
          it 'return message - Has been added already' do
            user.favoritecontents.create(content: post1)
            expect(json_response['messages']).to eq('Has been added already')
          end
        end
      end
    end
  end

  context 'when action remove_from_favorites' do
    context 'and user unauthorized' do
      it 'return unauthorized' do
        post :remove_from_favorites
        expect(response).to be_unauthorized
      end
    end

    context 'and user authorized' do
      let!(:user) { create(:user, token: 'token') }
      headers = { 'X-USER-TOKEN' => 'token' }
      before(:each) do
        request.headers.merge! headers
      end
      context 'and post or comment not found' do
        let(:response) { post :remove_from_favorites, params: { post_id: 1 } }
        it 'return not_found' do
          expect(response).to be_not_found
        end
      end

      context 'and post or comment exists' do
        let!(:post1) { create(:post) }
        let(:response) { post :remove_from_favorites, params: { post_id: post1.id } }
        before(:each) do
          user.favoritecontents.create(content: post1)
        end
        it 'return message - Remove from favorites' do
          expect(json_response['messages']).to eq('Remove from favorites')
        end

        it 'decreased contents count' do
          expect { response }.to change { user.favoritecontents.count }.by(-1)
        end
      end
    end
  end
end
