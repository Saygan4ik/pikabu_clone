RSpec.shared_examples 'upvote examples' do |object_type|
  context 'and user unauthorized' do
    it 'return unauthorized' do
      post :upvote, params: { post_id: 1 } if object_type == 'Post'
      post :upvote, params: { comment_id: 1 } if object_type == 'Comment'
      expect(response).to be_unauthorized
    end
  end

  context 'and user authorized' do
    let!(:user) { create(:user, token: 'token') }
    let!(:object) { create(:post) } if object_type == 'Post'
    let!(:post1) { create(:post) } if object_type == 'Comment'
    let!(:object) { create(:comment, commentable: post1) } if object_type == 'Comment'
    headers = { 'X-USER-TOKEN' => 'token' }
    before(:each) do
      request.headers.merge! headers
    end

    context "and we don't have #{object_type}" do
      it 'return 404' do
        post :upvote, params: { post_id: object.id + 1 } if object_type == 'Post'
        post :upvote, params: { comment_id: object.id + 1 } if object_type == 'Comment'
        expect(response).to be_not_found
      end
    end

    context "and we have #{object_type}" do
      let(:response) { post :upvote, params: { post_id: object.id } } if object_type == 'Post'
      let(:response) { post :upvote, params: { comment_id: object.id } } if object_type == 'Comment'

      it 'return 200' do
        expect(response).to be_success
      end

      it "return messages - #{object_type} is liked" do
        expect(json_response['messages']).to eq("#{object_type} is liked")
      end

      it "rating upgrade on #{object_type}" do
        expect{ response }
          .to change{ object.reload.cached_weighted_score }.from(0).to(1)
      end

      it 'rating upgrade on user' do
        expect{ response }.to change{ object.reload.user.rating }.from(0).to(1) if object_type == 'Post'
        expect{ response }.to change{ object.reload.user.rating }.from(0).to(0.5) if object_type == 'Comment'
      end

      context 'and was previously delivered to the like' do
        before(:each) do
          object.liked_by user
        end

        it "return message - User is already liked this #{object_type}" do
          expect(json_response['messages']).
            to eq("User is already liked this #{object_type}")
        end

        it "rating not upgrade on #{object_type}" do
          expect{ response }
            .to change{ object.cached_weighted_score }.by(0)
        end
      end

      context 'and was previously delivered to the dislike' do
        before(:each) do
          object.disliked_by user
        end

        it "return message - Remove dislike vote this #{object_type}" do
          expect(json_response['messages'])
            .to eq("Remove dislike vote this #{object_type}")
        end

        it "rating upgrade on #{object_type}" do
          expect{ response }
            .to change{ object.reload.cached_weighted_score }.from(-1).to(0)
        end
      end
    end
  end
end
