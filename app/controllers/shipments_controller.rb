class ShipmentsController < ApplicationController
  before_action :get_company, :get_shipment, only: [:show]

  def index
    @shipments = Shipment.includes(:shipment_items).all
  end

  def show
    serialized_shipment = ShipmentSerializer.new(@shipment, items_order: params[:items_order]).as_json

    render json: { shipment: serialized_shipment }
  end

  def tracking
    api_key = 'dummy_key'
    service = TrackingService.new(api_key, params[:id])
    response = service.call
    result = JSON.parse(response)

    if result["meta"]["code"] == 200
      render json: {
        status: result["data"]["tracking"]["tag"],
        current_location: result["data"]["tracking"]["checkpoints"][-1]["location"],
        last_checkpoint_message: result["data"]["tracking"]["checkpoints"][-1]["message"],
        last_checkpoint_time: result["data"]["tracking"]["checkpoints"][-1]["checkpoint_time"]
      }
    else
      render json: {
        meta: {
          code: 4004,
          message: "Tracking does not exist.",
          type: "BadRequest"
        }
      }, status: 404
    end
  end

  private

  def get_company
    return unless params[:company_id]

    @company = Company.find_by(id: params[:company_id])
    return unless @company.nil?

    render json: { error: "Company with ID #{params[:company_id]} not found" }, status: 404
  end

  def get_shipment
    @shipment = if @company
                  @company.shipments.find_by(id: params[:id])
                else
                  Shipment.find_by(id: params[:id])
                end

    return unless @shipment.nil?

    render json: { error: 'Shipment not found' }, status: 404
  end
end
