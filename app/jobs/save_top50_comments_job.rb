require_dependency 'app/services/top_comments'

class SaveTop50CommentsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    start_date = (Time.current - 1.day).beginning_of_day
    end_date = start_date.end_of_day
    @comments = TopComments.new([start_date, end_date]).find_top50
  end
end
