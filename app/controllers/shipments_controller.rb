require 'shipment_helper'
class ShipmentsController < ApplicationController
  include ShipmentHelper
  before_action :get_company, :get_shipment, only: [:show]

  def index
    @shipments = Shipment.all
  end

  def show
    @shipment = Shipment.find(params[:id])
    render 'show', formats: :json
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
end
