class DummyController < ApplicationController
  def index; end

  def success
    head :ok
  end

  def update
    head :ok
  end
end
