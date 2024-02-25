require 'rails_helper'
require 'webmock/rspec'

RSpec.describe ShipmentsController, type: :controller do
  let!(:company) { create(:company) }
  let!(:shipment) { create(:shipment, company: company, destination_country: 'USA', origin_country: 'HKG') }
  let!(:shipment_items) do
    create_list(:shipment_item, 3, description: 'Iphone', shipment: shipment)
  end

  describe '#show' do
    context 'when shipment exists' do
      it 'returns the shipment details' do
        parsed_formatted_time = shipment.created_at.strftime('%Y-%m-%dT%H:%M:%S.%LZ')
        expected_result = {
          'shipment' => {
            'company_id' => company.id,
            'destination_country' => shipment.destination_country,
            'origin_country' => shipment.origin_country,
            'tracking_number' => shipment.tracking_number,
            'slug' => shipment.slug,
            'created_at' => parsed_formatted_time,
            'items' => [{ 'description' => 'Iphone', 'count' => 3 }]
          }
        }
        get :show, params: { company_id: company.id, id: shipment.id }
        result = JSON.parse(response.body)
        expect(result).to eq(expected_result)
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
      tracking_id = shipment.tracking_number
      stub_request(:get, "https://api.aftership.com/tracking/2024-01/trackings/#{tracking_id}")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Aftership-Api-Key' => 'dummy_key',
            'Content-Type' => 'application/json',
            'User-Agent' => 'Ruby'
          }
        ).to_return(body: File.read('spec/fixtures/aftership/get_success_response.json'), status: 200)

      get :tracking, params: { company_id: company.id, id: tracking_id }

      expected_result = {
        'status' => 'InTransit',
        'current_location' => 'Singapore Main Office, Singapore',
        'last_checkpoint_message' => 'Received at Operations Facility',
        'last_checkpoint_time' => '2016-02-01T13:00:00'
      }

      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to eq(expected_result)
    end

    it 'returns an appropriate error message for a 404 response code' do
      tracking_id = shipment.tracking_number
      stub_request(:get, "https://api.aftership.com/tracking/2024-01/trackings/#{tracking_id}")
        .to_return(body: File.read('spec/fixtures/aftership/get_failure_response.json'), status: 404)

      get :tracking, params: { company_id: company.id, id: tracking_id }

      parsed_response = JSON.parse(response.body)
      expect(parsed_response['meta']['message']).to eq('Tracking does not exist.')
    end
  end

  describe 'POST search for shipments' do
    context 'when shipment size parameter is present' do
      it 'returns shipments with the specified size' do
        company2 = create(:company)
        shipment1 = create(:shipment, company: company2)
        shipment_items1 = create_list(:shipment_item, 3, description: 'Iphone', shipment: shipment1)
        parsed_formatted_time = shipment1.created_at.strftime('%Y-%m-%dT%H:%M:%S.%LZ')
        expected_result = [
          {
            'company_id' => company2.id,
            'destination_country' => shipment1.destination_country,
            'origin_country' => shipment1.origin_country,
            'tracking_number' => shipment1.tracking_number,
            'slug' => shipment1.slug,
            'created_at' => parsed_formatted_time,
            'items' => [{ 'description' => 'Iphone', 'count' => 3 }]
          }
        ]
        post :search, params: { company_id: company2.id, shipment_size: 3 }
        result = JSON.parse(response.body)
        expect(result).to eq(expected_result)
      end
    end
  end
end
