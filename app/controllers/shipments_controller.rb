class ShipmentsController < ApplicationController
  before_action :get_company, :get_shipment, only: [:show]

  def index
    @shipments = Shipment.all
  end

  def show
    grouped_shipment_items = @shipment.shipments_ordered_by_items_count(params[:items_order] || 'desc')
    render json: { company: @company, shipment: @shipment, grouped_shipment_items: grouped_shipment_items }
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
