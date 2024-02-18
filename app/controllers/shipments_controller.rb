class ShipmentsController < ApplicationController
  def index
    @shipments = Shipment.all
  end
end
