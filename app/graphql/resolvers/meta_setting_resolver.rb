# frozen_string_literal:true

module Resolvers
  class MetaSettingResolver
    def initialize(collection)
      @collection = collection
    end

    def setting_meta
      OpenStruct.new(current_page: @collection.current_page,
                     next_page: @collection.next_page,
                     prev_page: @collection.prev_page,
                     total_pages: @collection.total_pages,
                     total_count: @collection.total_count)
    end
  end
end
