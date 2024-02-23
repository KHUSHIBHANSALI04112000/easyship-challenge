require 'rails_helper'

RSpec.describe ShipmentsController, type: :controller do
  describe "show" do
    let(:company) { create(:company) }
    let(:shipment) { create(:shipment, company: company, destination_country: "USA", origin_country: "HKG") }

    context 'when shipment exists' do
      it 'returns the shipment details' do
        formatted_time = shipment.created_at.strftime("%a, %d %b %Y %H:%M:%S.%L %z %Z")
        parsed_formatted_time = Time.parse(formatted_time).strftime("%Y-%m-%dT%H:%M:%S.%LZ")
        expected_result = {
          "shipment" => {
            "company_id" => company.id,
            "destination_country" => shipment.destination_country,
            "origin_country" => shipment.origin_country,
            "tracking_number" => shipment.tracking_number,
            "slug" => shipment.slug,
            "created_at" => parsed_formatted_time,
            "items" => [{ "description" => "Iphone", "count" => 3 }]
          }
        }
        get :show, params: { company_id: company.id, id: shipment.id }
        result = JSON.parse(response.body)
        expect(result).to eq(expected_result)
      end
    end

    context 'when shipment does not exist' do
      before do
        get :show, params: { company_id: company.id, id: 1900002372473247 }
      end

      it 'returns an error message' do
        expect(JSON.parse(response.body)['error']).to eq('Shipment not found')
      end
    end

    context 'when company does not exist' do
      before do
        get :show, params: { company_id: 108999999, id: shipment.id }
      end

      it 'returns an error message' do
        expect(JSON.parse(response.body)['error']).to eq("Company with ID 108999999 not found")
      end
    end
  end
end
