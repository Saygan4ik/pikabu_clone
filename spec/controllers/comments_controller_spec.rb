# frozen_string_literal:true

require 'rails_helper'

describe Api::V1::CommentsController do
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

      context 'and post not exists' do
        it 'return not found' do
          post :create, params: { post_id: 1 }
          expect(response).to be_not_found
        end
      end

      context 'and post exists' do
        let!(:post1) { create(:post, user_id: user.id) }
        let!(:comments_count) { Comment.count }
        let!(:post_comments_count) { post1.comments.count }
        let!(:user_comments_count) { user.comments.count }
        let(:response) { post :create, params: { post_id: post1.id, comment: { text: 'text' } } }
        it 'return 200' do
          expect(response).to be_success
        end

        it 'quantity comments increased' do
          response
          expect(Comment.count).to eq(comments_count + 1)
          expect(post1.reload.comments.count).to eq(post_comments_count + 1)
          expect(user.reload.comments.count).to eq(user_comments_count + 1)
        end
      end
    end
  end

  context 'when action show' do
    context 'and we don\'t have comment' do
      it 'return not found' do
        get :show, params: { id: 1 }
        expect(response).to be_not_found
      end
    end

    context 'and we have comment' do
      let!(:post1) { create(:post) }
      let(:comment) { create(:comment, commentable: post1) }
      let(:response) { get :show, params: { id: comment.id } }

      it 'receive 2 comments' do
        expect(json_response['comment'])
          .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                              .new(comment).to_json)['comment'])
      end
    end
  end

  context 'when action upvote' do
    object_type = 'Comment'
    include_examples 'upvote examples', object_type
  end

  context 'when action downvote' do
    object_type = 'Comment'
    include_examples 'downvote examples', object_type
  end

  context 'when action top_comment' do
    let(:response) { get :top_comment }
    let!(:post1) { create(:post) }
    let!(:comment1) { create(:comment,
                            commentable: post1,
                            created_at: Time.current - 2.days,
                            cached_weighted_score: 9000) }
    context 'and we don\'t have top comment' do
      it 'receive empty array' do
        expect(json_response).to be_nil
      end
    end

    context 'and we have top comment' do
      let!(:comment2) { create(:comment,
                              commentable: post1,
                              created_at: Time.current - 23.hours,
                              cached_weighted_score: 1) }
      let!(:comment3) { create(:comment,
                              commentable: post1,
                              created_at: Time.current) }
      it 'receive 1 comment' do
        expect(json_response)
          .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                              .new(comment2).to_json))
      end
    end
  end

  context 'when action top50_comments' do
    let(:response) { get :top50_comments }
    context 'and we don\'t have comments' do
      it 'return empty array' do
        expect(json_response['comments']).to eq([])
      end
    end

    context 'and we have comments' do
      let!(:post1) { create(:post) }
      let!(:comments) { create_list(:comment, 10, commentable: post1) }
      context 'less 50' do
        it 'return 10 comments' do
          expect(json_response['comments'])
            .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                                .new(comments).to_json)['comments'])
        end
      end

      context 'more 50' do
        let!(:comments) { create_list(:comment, 60, commentable: post1) }
        it 'return 50 comments' do
          expect(json_response['comments'].count).to eq(50)
        end
      end

      context 'and getting date params' do
        context 'equal current day' do
          let(:response) { get :top50_comments, params: { date: Time.current } }
          it 'return 10 comments' do
            expect(json_response['comments'])
              .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                                  .new(comments).to_json)['comments'])
          end
        end

        context 'not equal current day' do
          let!(:comment) { create(:comment, commentable: post1, created_at: Time.current - 1.days) }
          let(:response) { get :top50_comments, params: { date: Time.current - 1.days } }
          let(:top_comment) { create( :top_comment, date: Time.current - 1.days, comment_id: comment.id) }

          it 'return 1 comment' do
            expect(json_response['comments'])
              .to eq(JSON.parse(ActiveModelSerializers::SerializableResource
                                  .new(comment).to_json)['comments'])
          end
        end
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
      let!(:comment1) { create(:comment, commentable: post1) }
      let!(:comment2) { create(:comment, commentable: comment1) }
      let(:response) { delete :destroy, params: { id: comment1.id } }
      let!(:comments_count) { Comment.count }

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
          expect(Comment.count).to eq(comments_count - 2)
        end
      end
    end
  end
end
