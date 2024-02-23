class ShipmentsController < ApplicationController
  before_action :get_company, only: [:show, :search]
  before_action :get_shipment, only: [:show]
  before_action :get_company_shipments, only: [:search]
  DEFAULT_SHIPMENT_SIZE = 10

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

  def search
    shipment_size = params[:shipment_size].presence || DEFAULT_SHIPMENT_SIZE
    shipments = @shipments.joins(:shipment_items)
                           .group('shipments.id')
                           .having('COUNT(shipment_items.id) = ?', shipment_size.to_i)
                           .select('shipments.*')

    shipment_items_collection = shipments.map { |shipment| ShipmentSerializer.new(shipment, items_order: params[:items_order]).as_json }
    shipments_hash = { "shipments" => shipment_items_collection }
    render json: shipments_hash
  end

  private

  def get_company
    if params[:company_id]
      begin
        @company = Company.find(params[:company_id].to_i)
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Company with ID #{params[:company_id]} not found" }, status: 404
      end
    end
  end

  def get_shipment
    if @company
      @shipment = @company.shipments.find_by(id: params[:id])
    else
      @shipment = Shipment.find_by(id: params[:id])
    end
    render json: { error: 'Shipment not found' }, status: 404 unless @shipment
  end

  def get_company_shipments
    @shipments = @company.shipments
    render json: { error: 'Shipment not found' }, status: 404 unless @shipments
  end
end
