require 'rails_helper'

RSpec.describe ShipmentsController, type: :controller do
  describe "show" do
    let(:company) { create(:company) }
    let(:shipment) { create(:shipment, company: company, destination_country: "USA", origin_country: "HKG") }

    context 'when shipment exists' do
      it 'returns the shipment details' do
        get :show, params: { company_id: company.id, id: shipment.id }
        result = JSON.parse(response.body)
        expect(result["shipment"]["company_id"]).to eq(company.id)
        expect(result["shipment"]["destination_country"]).to eq(shipment.destination_country)
        expect(result["shipment"]["origin_country"]).to eq(shipment.origin_country)
        expect(result["shipment"]["shipment_items"][0]["description"]).to eq(shipment.shipment_items[0].description)
        expect(result["shipment"]["shipment_items"][0]["count"]).to eq(shipment.shipment_items.size)
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
