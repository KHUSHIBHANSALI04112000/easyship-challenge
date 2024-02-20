class ShipmentsController < ApplicationController
  before_action :get_company, :get_shipment, only: [:show]

  def index
    @shipments = Shipment.all
  end

  def show
    grouped_shipment_items = @shipment.shipments_ordered_by_items_count(params[:items_order] || 'desc')
    render json: { company: @company, shipment: @shipment, grouped_shipment_items: grouped_shipment_items }
  end

  def tracking
    company_id = params[:company_id]
    shipment_id = params[:id]
    api_key = 'dummy_key'
  
    response = HTTParty.get(
      "https://api.aftership.com/v4/trackings/#{shipment_id}",
      headers: {
        'Content-Type' => 'application/json',
        'aftership-api-key' => api_key
      }
    )
  
    if response.code == 200
      result = JSON.parse(response.body)
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
      }, status: :not_found
    end
  end

  private

  def get_company
    @company = Company.find(params[:company_id])
  end

  def get_shipment
    if @company
      @shipment = @company.shipments.find_by(id: params[:id])
    else
      @shipment = Shipment.find_by(id: params[:id])
    end
    render json: { error: 'Shipment not found' }, status: :not_found unless @shipment
  end
end
