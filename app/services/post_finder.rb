class PostFinder
  def initialize(params)
    @params = params
  end

  def index_hot
    @posts = Post.all
    hot
    setting_date_parameters
    setting_order_parameters
    @posts.page(@params[:page]).per(@params[:per_page])
  end

  def index_best
    @posts = Post.all
    setting_date_parameters
    @posts
      .order(cached_weighted_score: :desc)
      .page(@params[:page]).per(@params[:per_page])
  end

  def index_new
    @posts = Post.all
    setting_date_parameters
    @posts
      .order(created_at: :desc)
      .page(@params[:page]).per(@params[:per_page])
  end

  def search
    @posts = Post.all
    setting_date_parameters(true)
    filter_rating
    filter_tags
    filter_search_data
    setting_order_parameters
    @posts.page(@params[:page]).per(@params[:per_page])
  end

  private

  def setting_date_parameters(skip_empty = false)
    start_date = Time.parse(@params[:start_date]).beginning_of_day if @params[:start_date]
    end_date = Time.parse(@params[:end_date]).end_of_day if @params[:end_date]
    if start_date && end_date
      @posts.where(created_at: start_date..end_date)
    elsif !start_date && end_date
      @posts.where('created_at <= ?', end_date)
    elsif start_date && !end_date
      @posts.where('created_at >= ?', start_date)
    else
      @posts.where(created_at: Time.current - 24.hours..Time.current) unless skip_empty
    end
  end

  def setting_order_parameters
    order_posts = @params[:order] == 'time' ? 'created_at' : 'cached_weighted_score'
    order_posts += @params[:order_by] == 'asc' ? ' ASC' : ' DESC'

    @posts = @posts.order(order_posts)
  end

  def hot
    @posts = @posts.where(isHot: true)
  end

  def filter_rating
    rating = @params[:rating]

    return unless rating
    raise ArgumentError, 'rating must be a number' unless rating.is_i?

    @posts = @posts.where('cached_weighted_score >= :rating', rating: rating.to_i)
  end

  def filter_tags
    return unless @params[:tags]
    @posts = @posts.joins(:tags)
    @params[:tags].split(' ').each do |tag|
      @posts = @posts.where(tags: { name: tag })
    end
  end

  def filter_search_data
    return unless @params[:search_data]
    @posts = @posts.where('title LIKE ?', "%#{@params[:search_data]}%")
  end
end
