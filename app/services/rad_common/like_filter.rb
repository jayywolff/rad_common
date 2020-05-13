module RadCommon
  ##
  # This is used to generate an input used for a SQL like filter
  class LikeFilter
    attr_reader :column
    ##
    # @param [String] column the database column that is being filtered
    # @param [Symbol] type the type of filter
    def initialize(column:, type:)
      @column = column
    end

    def filter_view
      'like'
    end

    def searchable_name
      like_input
    end

    def like_input
      "#{column}_like"
    end

    def apply_filter(results, params)
      value = like_value(params)

      results = results.where("lower(#{column}) like ?", "%#{value.downcase}%") if value.present?
      results
    end

    private

      def like_value(params)
        params[like_input]
      end
  end
end
