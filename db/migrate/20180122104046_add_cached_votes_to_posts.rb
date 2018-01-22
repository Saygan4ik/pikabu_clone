class AddCachedVotesToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :cached_votes_total, :integer, default: 0, index: true
    add_column :posts, :cached_votes_score, :integer, default: 0, index: true
    add_column :posts, :cached_votes_up, :integer, default: 0, index: true
    add_column :posts, :cached_votes_down, :integer, default: 0, index: true
    add_column :posts, :cached_weighted_score, :integer, default: 0, index: true
    add_column :posts, :cached_weighted_total, :integer, default: 0, index: true
    add_column :posts, :cached_weighted_average, :float, default: 0.0, index: true
  end
end
