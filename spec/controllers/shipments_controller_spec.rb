require 'rails_helper'
require 'webmock/rspec'

RSpec.describe ShipmentsController, type: :controller do
  let(:company) { create(:company) }
  let(:shipment) { create(:shipment, company: company, destination_country: "USA", origin_country: "HKG") }

  describe 'GET API for show method' do
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

  describe 'GET tracking information' do
    it 'returns tracking information if details available' do
      stub_request(:get, "https://api.aftership.com/v4/trackings/#{shipment.id}")
        .to_return(body: File.read('spec/fixtures/aftership/get_success_response.json'), status: 200)

      get :tracking, params: { company_id: company.id, id: shipment.id }

      expected_result = {
        "status": "InTransit",
        "current_location": "Singapore Main Office, Singapore",
        "last_checkpoint_message": "Received at Operations Facility",
        "last_checkpoint_time": "2016-02-01T13:00:00"
      }

      parsed_response = JSON.parse(response.body)
      expect(parsed_response["status"]).to eq(expected_result[:status])
      expect(parsed_response["current_location"]).to eq(expected_result[:current_location])
      expect(parsed_response["last_checkpoint_message"]).to eq(expected_result[:last_checkpoint_message])
      expect(parsed_response["last_checkpoint_time"]).to eq(expected_result[:last_checkpoint_time])
    end

    it 'returns an error message if tracking details are not available' do
      stub_request(:get, "https://api.aftership.com/v4/trackings/#{shipment.id}")
        .to_return(body: File.read('spec/fixtures/aftership/get_failure_response.json'), status: 404)

      get :tracking, params: { company_id: company.id, id: shipment.id }

      parsed_response = JSON.parse(response.body)
      expect(parsed_response["meta"]["message"]).to eq("Tracking does not exist.")
    end
  end
end

