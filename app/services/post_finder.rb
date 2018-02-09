# frozen_string_literal: true

class PostFinder
  def initialize(params)
    @params = params
    @query = '*'
    @filter = { where: {} }
  end

  def index_hot
    @posts = Post.all
    hot
    setting_date_parameters
    filter_community
    setting_order_parameters
    paginated_posts
  end

  def index_best
    @posts = Post.all
    setting_date_parameters
    filter_community
    @filter[:order] = { rating: :desc }
    paginated_posts
  end

  def index_new
    @posts = Post.all
    setting_date_parameters
    filter_community
    @filter[:order] = { created_at: :desc }
    paginated_posts
  end

  def search
    @posts = Post.all
    setting_date_parameters(true)
    filter_user
    filter_community
    filter_rating
    filter_tags
    filter_search_data
    setting_order_parameters
    paginated_posts
  end

  private

  def setting_date_parameters(skip_empty = false)
    start_date = Time.parse(@params[:start_date]).beginning_of_day if @params[:start_date]
    end_date = Time.parse(@params[:end_date]).end_of_day if @params[:end_date]
    if start_date && end_date
      @filter[:where][:created_at] = start_date.to_i..end_date.to_i
    elsif !start_date && end_date
      @filter[:where][:created_at] = Time.parse('1970-01-01').to_i..end_date.to_i
    elsif start_date && !end_date
      @filter[:where][:created_at] = start_date.to_i..Time.current.to_i
    else
      @filter[:where][:created_at] = (Time.current - 24.hours).to_i..Time.current.to_i unless skip_empty
    end
  end

  def setting_order_parameters
    order_field = @params[:order] == 'time' ? 'created_at' : 'rating'
    order_by = @params[:order_by] == 'asc' ? 'asc' : 'desc'

    @filter[:order] = { order_field.to_sym => order_by.to_sym }
  end

  def hot
    @filter[:where][:isHot] = true
  end

  def filter_community
    @filter[:where][:community_id] = @params[:community_id] if @params[:community_id]
  end

  def filter_rating
    rating = @params[:rating]

    return unless rating
    raise ArgumentError, 'rating must be a number' unless rating.is_i?

    @filter[:where][:rating] = { gte: rating.to_i }
  end

  def filter_tags
    return unless @params[:tags] && !@params[:tags].empty?
    tag_ids = []
    missing_tags = []
    @params[:tags].split(' ').each do |tag|
      database_tag = Tag.find_by(name: tag)
      database_tag ? tag_ids << database_tag.id : missing_tags << tag
    end

    raise ArgumentError, "tags don't exists - #{missing_tags.join(', ')}" if missing_tags.any?
    @filter[:where][:tag_ids] = { all: tag_ids } if tag_ids.any?
  end

  def filter_search_data
    return unless @params[:search_data].present?
    @query = @params[:search_data]
  end

  def filter_user
    return unless @params[:user_id]
    @filter[:where][:user_id] = @params[:user_id].to_i
  end

  def paginated_posts
    @filter[:where][:page] = @params[:page] if @params[:page]
    @filter[:where][:per_page] = @params[:per_page] if @params[:per_page]
    @filter[:match] = :word_start

    Post.searchkick_index.refresh if Rails.env.test?
    Post.search(@query, @filter)
  end
end
