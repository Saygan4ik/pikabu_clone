# frozen_string_literal:true

require 'rails_helper'

describe Api::V1::PostsController do
  context 'when action index' do
    let(:response) { get :index }
    context 'and we don\'t have any post' do

      it 'return 200' do
        expect(response).to be_success
      end

      it 'receive empty array' do
        expect(json_response['posts']).to eq([])
      end
    end

    context 'and we have 2 posts' do
      let!(:posts) { create_list(:post, 2) }

      it 'receive 2 posts' do
        expect(json_response['posts'])
          .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                            .new([posts[1], posts[0]]).to_json)['posts'])
      end
    end
  end

  context 'when action hot' do
    let(:response) { get :hot }
    context 'and we don\'t have hot posts' do
      let!(:posts) { create_list(:post, 2) }

      it 'return 200' do
        expect(response).to be_success
      end

      it 'receive empty array' do
        expect(json_response['posts']).to eq([])
      end
    end

    context 'and we have hot posts' do
      let!(:posts) { create_list(:post, 2) }
      let!(:hot_post) { create(:post, isHot: true) }

      it 'return 200' do
        expect(response).to be_success
      end

      it 'receive 1 hot post' do
        expect(json_response['posts'])
          .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                              .new([hot_post]).to_json)['posts'])
      end
    end
  end

  context 'when action best' do
    let!(:post1) { create(:post, cached_weighted_score: 1) }
    let!(:post2) { create(:post, cached_weighted_score: 2) }
    let(:response) { get :best }

    it 'return 200' do
      expect(response).to be_success
    end

    it 'receive 2 posts ordered by rating' do
      expect(json_response['posts'])
        .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                            .new([post2, post1]).to_json)['posts'])
    end
  end

  context 'when action recent' do
    let!(:post1) { create(:post, created_at: Time.current - 1.minutes) }
    let!(:post2) { create(:post, created_at: Time.current) }
    let(:response) { get :recent }

    it 'return 200' do
      expect(response).to be_success
    end

    it 'receive 2 posts ordered by date created' do
      expect(json_response['posts'])
        .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                            .new([post2, post1]).to_json)['posts'])
    end
  end

  context 'when action show' do
    context 'and we don\'t have this post' do
      it 'return 404' do
        get :show, params: { id: 1 }
        expect(response).to be_not_found
      end
    end

    context 'and we have this post' do
      let!(:post1) { create(:post) }
      let(:response) { get :show, params: { id: post1.id } }

      it 'return 200' do
        expect(response).to be_success
      end

      it 'receive 1 post' do
        expect(json_response['post']).to eq(JSON.parse(PostSerializer.new(post1).to_json))
      end

      context 'with comments' do
        let!(:comment1) { create(:comment,
                                 commentable: post1,
                                 cached_weighted_score: 1,
                                 created_at: Time.current) }
        let!(:comment2) { create(:comment,
                                 commentable: post1,
                                 cached_weighted_score: 2,
                                 created_at: Time.current - 1.minutes) }

        context 'and order by date' do
          it 'receive post with comments, ordered by date' do
            expect(json_response['post']['comments'])
              .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                                  .new([comment1, comment2]).to_json)['comments'])
          end
        end

        context 'and order by rating' do
          let(:response) { get :show, params: { id: post1.id, order: 'rating' } }

          it 'receive post with comments, ordered by rating' do
            expect(json_response['post']['comments'])
              .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                                  .new([comment2, comment1]).to_json)['comments'])
          end
        end
      end
    end
  end

  context 'when action upvote' do
    object_type = 'Post'

    include_examples 'upvote examples', object_type
  end

  context 'when action downvote' do
    object_type = 'Post'

    include_examples 'downvote examples', object_type
  end

  context 'when action search' do
    let!(:tag1) { create(:tag, name: 'tag1') }
    let!(:tag2) { create(:tag, name: 'tag2') }
    let!(:tag3) { create(:tag, name: 'tag3') }
    let!(:post1) { create(:post,
                          title: 'aaa bbb ccc', created_at: Time.current,
                          cached_weighted_score: 3,
                          tags: [tag1, tag2]) }
    let!(:post2) { create(:post,
                          title: 'aaa', created_at: Time.current - 1.hours,
                          cached_weighted_score: 2,
                          tags: [tag1, tag3]) }
    let!(:post3) { create(:post,
                          title: 'aaabbb', created_at: Time.current - 2.days,
                          cached_weighted_score: 1,
                          tags: [tag2, tag3]) }
    let!(:post4) { create(:post, title: 'aaa', created_at: Time.current - 3.days) }

    context 'and getting search_data params' do
      it 'receive 1 post' do
        get :search, params: { search_data: 'aaa bbb' }
        expect(json_response['posts'])
          .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                              .new([post1]).to_json)['posts'])
      end
    end

    context 'and no getting params start_date, end_date' do
      it 'receive all posts' do
        get :search, params: { search_data: 'aaa' }
        expect(json_response['posts'])
          .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                              .new([post1, post2, post3, post4]).to_json)['posts'])
      end
    end

    context 'and getting params start_date' do
      it 'receive 3 posts' do
        get :search, params: { search_data: 'aaa', start_date: Time.current - 2.days }
        expect(json_response['posts'])
          .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                              .new([post1, post2, post3]).to_json)['posts'])
      end
    end

    context 'and getting params end_date' do
      it 'receive 2 posts' do
        get :search, params: { search_data: 'aaa', end_date: Time.current - 1.days }
        expect(json_response['posts'])
          .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                              .new([post3, post4]).to_json)['posts'])
      end
    end

    context 'and getting params start_date, end_date' do
      it 'receive 1 posts' do
        get :search, params: { search_data: 'aaa',
                               start_date: Time.current - 2.days,
                               end_date: Time.current - 1.days }
        expect(json_response['posts'])
          .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                              .new([post3]).to_json)['posts'])
      end
    end

    context 'and getting params order and order_by' do
      it 'receive 1,2,3,4 posts with time-desc' do
        get :search, params: { search_data: 'aaa',
                               order: 'time',
                               order_by: 'desc' }
        expect(json_response['posts'])
          .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                              .new([post1, post2, post3, post4]).to_json)['posts'])
      end

      it 'receive 4,3,2,1 posts with time-asc' do
        get :search, params: { search_data: 'aaa',
                               order: 'time',
                               order_by: 'asc' }
        expect(json_response['posts'])
          .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                              .new([post4, post3, post2, post1]).to_json)['posts'])
      end

      it 'receive 1,2,3,4 posts with rating-asc' do
        get :search, params: { search_data: 'aaa',
                               order: 'rating',
                               order_by: 'asc' }
        expect(json_response['posts'])
          .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                              .new([post4, post3, post2, post1]).to_json)['posts'])
      end

      it 'receive 4,3,2,1 posts with rating-desc' do
        get :search, params: { search_data: 'aaa',
                               order: 'rating',
                               order_by: 'desc' }
        expect(json_response['posts'])
          .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                              .new([post1, post2, post3, post4]).to_json)['posts'])
      end
    end

    context 'and getting user_id' do
      let!(:user1) { create(:user) }
      let!(:user2) { create(:user) }
      let!(:post5) { create(:post, title: 'aaa', user_id: user1.id) }
      it 'receive post5' do
        get :search, params: { search_data: 'aaa', user_id: user1.id }
        expect(json_response['posts'])
          .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                              .new([post5]).to_json)['posts'])
      end

      it 'return empty array' do
        get :search, params: { search_data: 'aaa', user_id: user2.id }
        expect(json_response['posts']).to eq([])
      end
    end

    context 'and getting rating' do
      it 'receive 2 posts' do
        get :search, params: { search_data: 'aaa', rating: '2' }
        expect(json_response['posts'])
          .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                              .new([post1, post2]).to_json)['posts'])
      end
    end

    context 'and getting tags' do
      it 'receive 2 posts' do
        get :search, params: { search_data: 'aaa', tags: 'tag2' }
        expect(json_response['posts'])
          .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                              .new([post1, post3]).to_json)['posts'])
      end

      it 'receive 1 post' do
        get :search, params: { search_data: 'aaa', tags: 'tag2 tag3' }
        expect(json_response['posts'])
          .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                              .new([post3]).to_json)['posts'])
      end

      it 'return empty array' do
        get :search, params: { search_data: 'aaa', tags: 'tag4' }
        expect(json_response['posts']).to eq([])
      end
    end
  end

  context 'when action create' do
    context 'and user unauthorized' do
      it 'return unauthorized' do
        post :create
        expect(response).to be_unauthorized
      end
    end

    context 'and user authorized' do
      let!(:user) { create(:user, token: 'token') }
      headers = { 'X-USER-TOKEN' => 'token' }
      before(:each) do
        request.headers.merge! headers
      end
      let!(:post_count) { Post.count }
      let!(:tag_count) { Tag.count }
      let(:response) { post :create, params: { post: { title: 'title', text: 'text', tags: 'tag1 tag2' } } }

      it 'return 200' do
        expect(response).to be_success
      end

      it 'quantity posts increased' do
        response
        expect(Post.count).to eq(post_count + 1)
      end

      it 'saving new tags' do
        response
        expect(Tag.count).to eq(tag_count + 2)
      end
    end
  end

  context 'when action destroy' do
    context 'and user unauthorized' do
      it 'return unauthorized' do
        delete :destroy, params: { id: 1 }
        expect(response).to be_unauthorized
      end
    end

    context 'and user authorized' do
      let!(:user) { create(:user, token: 'token') }
      headers = { 'X-USER-TOKEN' => 'token' }
      before(:each) do
        request.headers.merge! headers
      end
      let!(:post1) { create(:post, user_id: user.id) }
      let(:response) { delete :destroy, params: { id: post1.id } }
      let!(:post_count) { Post.count }

      context 'and user is not admin' do
        it 'return forbidden' do
          expect(response).to be_forbidden
        end
      end

      context 'and user is admin' do
        it 'return success' do
          user.role = :admin
          user.save
          expect(response).to be_success
          expect(Post.count).to eq(post_count - 1)
        end

        context 'and after deleting' do
          let!(:user1) { create(:user, rating: 3) }
          let!(:user2) { create(:user) }
          let!(:post2) { create(:post, user_id: user1.id, cached_weighted_score: 2) }
          let!(:comment1) { create(:comment, commentable: post2, user_id: user1.id, cached_weighted_score: 1) }
          let!(:comment2) { create(:comment, commentable: comment1, user_id: user1.id, cached_weighted_score: 1) }
          let(:response) { delete :destroy, params: { id: post2.id } }

          it 're-count users rating' do
            expect{ response }.to change{ user1.reload.rating }.from(3).to(0)
          end
        end
      end
    end
  end
end
