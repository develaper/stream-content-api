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
        service = CatalogEntryService.new(@country_code)
        @content = service.list(model&.name)
        render json: @content
      end

      # GET /api/v1/content/:id
      # Optional params: user_id (for channel programs to get time_watched)
      #
      def show
        service = CatalogEntryService.new(@country_code)
        item = service.find(params[:id], params[:user_id])
        return render(json: { error: "Content not found" }, status: :not_found) unless item
        render json: item
      end

      # GET /api/v1/content/favorites
      # Required params: user_id
      #
      def favorite_channel_programs
        user_id = params[:user_id]
        return render(json: { error: "user_id parameter is required" }, status: :bad_request) unless user_id.present?
        favorites = FavoriteChannelProgramsService.new(user_id).favorites
        render json: favorites
      end

      # GET /api/v1/content/search
      # Required params: query
      #
      def search
        permitted = params.permit(:query)
        query = permitted[:query]
        return render(json: { error: "query parameter is required" }, status: :bad_request) if query.blank?

        results = ContentSearchService.new(query).results
        render json: results
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
    end
  end
end
