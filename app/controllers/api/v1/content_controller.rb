
module Api
  module V1
    class ContentController < BaseController
      before_action :require_country, only: [ :index ]

      # GET /api/v1/content
      # Required params: country
      # Optional params: type (movie, tv_show, channel, app)
      #
      def index
        if params[:type].present?
          model = content_models[params[:type].downcase]

          return render(json: { error: "Invalid content type" }, status: :bad_request) if model.nil?
        end
        entries = catalog_entries_for_market(model&.name)
        @content = entries.map { |entry| ContentItem.new(entry.content) }

        render json: @content
      end

      # GET /api/v1/content/:id
      # Optional params: user_id (for channel programs to get time_watched)
      #
      def show
        entry = CatalogEntry.find_by(content_id: params[:id])
        return render(json: { error: "Content not found" }, status: :not_found) unless entry

        content = entry.content

        render json: ContentItem.new(content, user_id: params[:user_id])
      end

      private

      def content_models
        Contentable.registered.index_by { |klass| klass.name.underscore }
      end

      def require_country
        unless params[:country].present?
          render json: { error: "Country parameter is required" }, status: :bad_request
          return false
        end
        @country_code = params[:country].upcase
      end

      def catalog_entries_for_market(content_type = nil)
        scope = CatalogEntry
          .joins("INNER JOIN content_availabilities ON content_availabilities.content_id = catalog_entries.content_id AND content_availabilities.content_type = catalog_entries.content_type")
          .joins("INNER JOIN markets ON content_availabilities.market_id = markets.id")
          .where(markets: { code: @country_code })
          .distinct
        content_type ? scope.where(content_type: content_type) : scope
      end
    end
  end
end
