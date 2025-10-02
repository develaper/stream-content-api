module Api
  module V1
    class BaseController < ApplicationController
      protected

      def render_not_found(resource_name = "Resource")
        render json: { error: "#{resource_name} not found" }, status: :not_found
      end

      def render_validation_errors(errors)
        render json: { errors: errors }, status: :unprocessable_entity
      end
    end
  end
end
