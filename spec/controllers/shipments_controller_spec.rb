require 'rails_helper'

RSpec.describe ShipmentsController, type: :controller do
  describe 'GET #show' do
    let!(:company) { Company.create(name: "Test Company") }
    let!(:shipment) { Shipment.create(company: company, destination_country: "USA", origin_country: "HKG") }

    context 'when shipment exists' do
      it 'returns the shipment details' do
        get :show, params: { company_id: company.id, id: shipment.id }
        result = JSON.parse(response.body)
        expect(result["shipment"]["company_id"]).to eq(company.id)
        expect(result["shipment"]["destination_country"]).to eq(shipment.destination_country)
        expect(result["shipment"]["origin_country"]).to eq(shipment.origin_country)
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
