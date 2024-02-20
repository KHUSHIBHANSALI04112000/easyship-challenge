require 'shipment_helper'
class ShipmentsController < ApplicationController
  include ShipmentHelper
  before_action :get_company, only: [:show, :search]
  before_action :get_shipment, only: [:show]
  before_action :get_company_shipments, only: [:search]

  def index
    @shipments = Shipment.all
  end

  def show
    result = transform_shipment_data(@shipment)
    render json: result
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
      }, status: 404
    end
  end

  def search
    company_shipments = @company.shipments

    # Search shipments by number of items
    if params[:shipment_size].present?
      shipments = Shipment.where(company_id: params[:company_id])
                    .joins(:shipment_items)
                    .group('shipments.id')
                    .having('COUNT(shipment_items.id) = ?', params[:shipment_size].to_i)
                    .select('shipments.*')
    end

    render json: shipments
  end


  private

  def get_company
    if params[:company_id]
      begin
        @company = Company.find(params[:company_id])
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
    if @company
      @shipments = @company.shipments.where(company_id: params[:company_id])
    else
      @shipments = Shipment.find_by(id: params[:id])
    end
    render json: { error: 'Shipment not found' }, status: :not_found unless @shipments
  end
end