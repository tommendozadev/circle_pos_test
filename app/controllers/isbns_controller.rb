class IsbnsController < ApplicationController
  def create
    @input  = params[:isbn].to_s
    @result = Isbn.complete(@input)

    respond_to do |format|
      format.html { render :new }
      format.json { render json: { input: @input, isbn13: @result } }
    end
  rescue Isbn::InvalidInputError => e
    @error = e.message

    respond_to do |format|
      format.html { render :new, status: 422 }
      format.json { render json: { error: @error }, status: 422 }
    end
  end
end
