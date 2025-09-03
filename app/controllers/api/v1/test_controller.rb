class Api::V1::TestController < ApplicationController
  def index
    @test = Test.all
    render json: @test
  end

  def create
    @test = Test.create(test_params)
    render json: @test
  end

  private

  def test_params
    params.require(:test).permit(:description)
  end
end
