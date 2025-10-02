module Api
  module V1
    class AppsController < BaseController
      before_action :require_user_id, only: [ :favorites, :favorite ]
      # GET /api/v1/apps/favorites
      # Required params: user_id
      #
      def favorites
        favorite_apps = UserFavoriteApp.by_user(@user_id).includes(:app)

        render json: favorite_apps.map { |fa| AppItem.new(fa.app, position: fa.position).as_json }
      end

      # POST /api/v1/apps/favorite
      # Required params: user_id, app_id, position
      #
      def favorite
        attrs = favorite_params
        app_id = attrs[:app_id]
        position = attrs[:position]

        return render(json: { error: "Missing parameters" }, status: :bad_request) unless app_id && position

        favorite_app = UserFavoriteApp.find_or_initialize_by(user_identifier: @user_id, app_id: app_id)
        favorite_app.position = position

        if favorite_app.save
          render json: AppItem.new(favorite_app.app, position: favorite_app.position).as_json.merge(success: true)
        else
          render json: { error: favorite_app.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private
      def require_user_id
        unless params[:user_id].present?
          render json: { error: "user_id parameter is required" }, status: :bad_request
          return false
        end

        @user_id = params[:user_id]
      end

      def favorite_params
        params.permit(:app_id, :position)
      end
    end
  end
end
