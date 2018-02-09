# frozen_string_literal:true

require 'rails_helper'

describe Api::V1::CommunitiesController do
  context 'when action index' do
    let(:response) { get :index }
    context 'and we don\'t have any communities' do

      it 'return 200' do
        expect(response).to be_success
      end

      it 'receive empty array' do
        expect(json_response['communities']).to eq([])
      end
    end

    context 'and we have 2 communities' do
      let!(:communities) { create_list(:community, 2) }

      it 'receive 2 communities' do
        expect(json_response['communities'])
          .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                              .new(communities).to_json)['communities'])
      end
    end
  end

  context 'when action show' do
    context 'and we dont\'t have community' do
      let(:response) { get :show, params: { id: 1 } }
      it 'return not found' do
        expect(response).to be_not_found
      end
    end

    context 'and we have community' do
      let(:community) { create(:community) }
      let(:response) { get :show, params: { id: community.id } }
      it 'return 200' do
        expect(response).to be_success
      end

      it 'receive 1 community' do
        expect(json_response)
          .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                              .new(community).to_json))
      end
    end
  end

  context 'when action subscribe' do
    let(:community) { create(:community) }
    let(:response) { post :subscribe, params: { id: community.id } }
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
      context 'and not subscribed previously' do
        it 'return 200' do
          expect(response).to be_success
        end
        it 'return message - Thank you to subscribe' do
          expect(json_response['messages']).to eq('Thank you to subscribe')
        end
        it 'added community to user' do
          response
          expect(user.communities.first).to eq(community)
        end
      end

      context 'and subscribed previously' do
        it 'return message - You are already subscribed' do
          user.communities << community
          user.save
          expect(json_response['messages']).to eq('You are already subscribed')
        end
      end
    end
  end

  context 'when action unsubscribe' do
    let(:community) { create(:community) }
    let(:response) { post :unsubscribe, params: { id: community.id } }
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
      context 'and subscribed previously' do
        before(:each) do
          user.communities << community
          user.save
        end
        it 'return 200' do
          expect(response).to be_success
        end
        it 'return message - You unsubscribe from community' do
          expect(json_response['messages']).to eq('You unsubscribe from community')
        end
        it 'remove community to user' do
          response
          expect(user.reload.communities).to eq([])
        end
      end

      context 'and not subscribed previously' do
        it 'return message - You do not belong to the community' do
          expect(json_response['messages']).to eq('You do not belong to the community')
        end
      end
    end
  end

  context 'when action posts_new' do
    let(:community) { create(:community) }
    let!(:posts_without_community) { create_list(:post, 2) }
    let!(:post_with_community) { create(:post, community_id: community.id) }
    let(:response) { get :posts_new, params: { id: community.id } }
    it 'return 1 posts' do
      expect(json_response['posts'])
        .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                            .new([post_with_community]).to_json)['posts'])
    end
  end

  context 'when action posts_subscriptions' do
    let(:community1) { create(:community) }
    let(:community2) { create(:community) }
    let(:community3) { create(:community) }
    let!(:user) { create(:user, token: 'token') }
    let!(:posts_without_community) { create_list(:post, 2) }
    let!(:post_with_community1) { create(:post, community_id: community1.id) }
    let!(:post_with_community2) { create(:post, community_id: community2.id) }
    let!(:post_with_community3) { create(:post, community_id: community3.id) }
    let(:response) { get :posts_subscriptions }
    context 'and user unauthorized' do
      it 'return unauthorized' do
        expect(response).to be_unauthorized
      end
    end

    context 'and user authorized' do
      headers = { 'X-USER-TOKEN' => 'token' }
      before(:each) do
        request.headers.merge! headers
      end
      context 'and don\'t have subscriptions' do
        it 'return 404' do
          expect(response).to be_not_found
        end
      end

      context 'and have subscriptions' do
        before do
          user.communities << community1
          user.communities << community2
          user.save
        end
        it 'return 200' do
          expect(response.status).to be(200)
        end

        it 'receive 2 posts' do
          expect(json_response['posts'])
            .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                                .new([post_with_community1, post_with_community2]).to_json)['posts'])
        end
      end
    end
  end
end
