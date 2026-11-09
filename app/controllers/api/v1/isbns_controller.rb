# app/controllers/api/v1/isbns_controller.rb
module Api
  module V1
    class IsbnsController < ActionController::API
      wrap_parameters false   # keep the JSON body flat in params

      def create
        request_object = IsbnRequest.new(isbn: params[:isbn])
        unless request_object.valid?
          return render json: IsbnSerializer.error(**request_object.error), status: :bad_request
        end

        isbn13 = Isbn.complete(request_object.isbn)
        render json: IsbnSerializer.new(isbn13).as_json, status: :ok
      rescue Isbn::InvalidInputError => e
        render json: IsbnSerializer.error(code: "invalid_isbn", message: e.message), status: 422
      end
    end
  end
end
