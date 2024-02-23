require 'rails_helper'
require 'webmock/rspec'

RSpec.describe ShipmentsController, type: :controller do
  let(:company) { create(:company) }
  let(:shipment) do
    create(:shipment, company: company,
                      tracking_number: SecureRandom.random_number(100_000..999_999),
                      destination_country: 'USA',
                      origin_country: 'HKG')
  end

  describe 'GET API for show method' do
    context 'when shipment exists' do
      it 'returns the shipment details' do
        get :show, params: { company_id: company.id, id: shipment.id }
        result = JSON.parse(response.body)
        expect(result['shipment']['company_id']).to eq(company.id)
        expect(result['shipment']['destination_country']).to eq(shipment.destination_country)
        expect(result['shipment']['origin_country']).to eq(shipment.origin_country)
        expect(result['shipment']['shipment_items'][0]['description']).to eq(shipment.shipment_items[0].description)
        expect(result['shipment']['shipment_items'][0]['count']).to eq(shipment.shipment_items.size)
      end
    end

    context 'when shipment does not exist' do
      it 'returns an error message' do
        get :show, params: { company_id: company.id, id: 1_900_002_372_473_247 }
        expect(JSON.parse(response.body)['error']).to eq('Shipment not found')
      end
    end

    context 'when company does not exist' do
      it 'returns an error message' do
        get :show, params: { company_id: 108_999_999, id: shipment.id }
        expect(JSON.parse(response.body)['error']).to eq("Company with ID 108999999 not found")
      end
    end
  end

  describe 'GET tracking information' do
    it 'returns tracking information if details available' do
      stub_request(:get, "https://api.aftership.com/tracking/2024-01/trackings/#{shipment.tracking_number}")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Aftership-Api-Key' => 'dummy_key',
            'Content-Type' => 'application/json',
            'User-Agent' => 'Ruby'
          }).to_return(body: File.read('spec/fixtures/aftership/get_success_response.json'), status: 200)
      
      get :tracking, params: { company_id: company.id, id: shipment.tracking_number }

      expected_result = {
        'status' => 'InTransit',
        'current_location' => 'Singapore Main Office, Singapore',
        'last_checkpoint_message' => 'Received at Operations Facility',
        'last_checkpoint_time' => '2016-02-01T13:00:00'
      }

      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to eq(expected_result)
    end

    it 'returns an error message if tracking details are not available' do
      tracking_id = shipment.tracking_number
      stub_request(:get, "https://api.aftership.com/tracking/2024-01/trackings/#{tracking_id}")
        .to_return(body: File.read('spec/fixtures/aftership/get_failure_response.json'), status: 404)

      get :tracking, params: { company_id: company.id, id: tracking_id }

      parsed_response = JSON.parse(response.body)
      expect(parsed_response['meta']['message']).to eq('Tracking does not exist.')
    end
  end
end

