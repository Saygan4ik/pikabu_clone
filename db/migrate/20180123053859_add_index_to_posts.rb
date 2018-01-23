class AddIndexToPosts < ActiveRecord::Migration[5.1]
  def change
    add_index  :posts, :cached_votes_total
    add_index  :posts, :cached_votes_score
    add_index  :posts, :cached_votes_up
    add_index  :posts, :cached_votes_down
    add_index  :posts, :cached_weighted_score
    add_index  :posts, :cached_weighted_total
    add_index  :posts, :cached_weighted_average
  end
end
