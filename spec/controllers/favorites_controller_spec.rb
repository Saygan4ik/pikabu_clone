# frozen_string_literal:true

require 'rails_helper'

describe Api::V1::FavoritesController do
  context 'when action index' do
    let(:response) { get :index }
    context 'and user unauthorized' do
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
      context 'and user don\'t have favorites' do
        it 'return message - No favorites created' do
          expect(json_response['messages']).to eq('No favorites created')
        end
      end

      context 'and user have favorites' do
        let!(:favorite1) { create(:favorite) }
        let!(:favorite2) { create(:favorite) }
        let(:post1) { create(:post) }
        it 'return 2 favorites' do
          user.favoritecontents.create(content: post1, favorite_id: favorite1.id)
          user.favoritecontents.create(content: post1, favorite_id: favorite2.id)
          expect(json_response)
            .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                                .new([favorite1, favorite2]).to_json))
        end
      end
    end
  end

  context 'when action show' do
    let(:response) { get :show, params: { id: 1 } }
    context 'and user unauthorized' do
      it 'return unauthorized' do
        expect(response).to be_unauthorized
      end
    end

    context 'and user authorized' do
      let!(:user1) { create(:user, token: 'token') }
      let!(:user2) { create(:user) }
      let!(:favorite1) { create(:favorite) }
      let!(:favorite2) { create(:favorite) }
      let!(:post1) { create(:post) }
      let!(:post2) { create(:post) }
      let!(:post3) { create(:post) }
      let!(:comment) { create(:comment, commentable: post1) }
      let(:response) { get :show, params: { id: favorite1.id } }
      headers = { 'X-USER-TOKEN' => 'token' }
      before(:each) do
        request.headers.merge! headers
      end
      context 'and user don\'t have contents in favorites' do
        it 'return not found' do
          expect(response).to be_not_found
        end
      end
      context 'and user have contents in favorites' do
        it 'return 1 post and 1 comment' do
          user1.favoritecontents.create(content: post1, favorite_id: favorite1.id)
          user1.favoritecontents.create(content: post2, favorite_id: favorite2.id)
          user1.favoritecontents.create(content: comment, favorite_id: favorite1.id)
          user2.favoritecontents.create(content: post1, favorite_id: favorite1.id)
          expect(json_response)
            .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                                .new([post1, comment]).to_json))
        end
      end
    end
  end

  context 'when action content' do
    let(:response) { get :contents }
    context 'and user unauthorized' do
      it 'return unauthorized' do
        expect(response).to be_unauthorized
      end
    end

    context 'and user authorized' do
      let!(:user) { create(:user, token: 'token') }
      let!(:favorite1) { create(:favorite) }
      let!(:favorite2) { create(:favorite) }
      let!(:post1) { create(:post) }
      let!(:post2) { create(:post) }
      let!(:comment) { create(:comment, commentable: post1) }
      let(:response) { get :contents }
      headers = { 'X-USER-TOKEN' => 'token' }
      before(:each) do
        request.headers.merge! headers
      end
      context 'and user don\'t have contents' do
        it 'return not found' do
          expect(response).to be_not_found
        end
      end
      context 'and user have contents' do
        it 'return 2 post and 1 comment' do
          user.favoritecontents.create(content: post1, favorite_id: favorite1.id)
          user.favoritecontents.create(content: post2, favorite_id: favorite2.id)
          user.favoritecontents.create(content: comment, favorite_id: favorite1.id)
          expect(json_response)
            .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                                .new([post1, post2, comment]).to_json))
        end
      end
    end
  end
end
