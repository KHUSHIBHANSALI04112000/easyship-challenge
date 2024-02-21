require 'rails_helper'

RSpec.describe Shipment, type: :model do

  let(:company) { create(:company) }
  let(:shipment) { create(:shipment, company: company) }

  context 'fetch shipments ordered by count with respective decription ' do
    before do
      item_1 = create(:shipment_item, description: 'Iphone', shipment: shipment)
      item_2 = create(:shipment_item, description: 'Macbook air', shipment: shipment)
      item_3 = create(:shipment_item, description: 'Iphone', shipment: shipment)
    end

    it 'should return  shipments ordered by item count in descending order if order specified is descending' do

      ordered_shipments = shipment.shipments_ordered_by_items_count('dsc')

      expect(ordered_shipments).to eq([
        { description: 'Iphone', count: 2 },
        { description: 'Macbook air', count: 1 },
      ])
    end

    it 'should return shipments ordered by item count in ascending order if order specified is ascending' do
      ordered_shipments = shipment.shipments_ordered_by_items_count('asc')

      expect(ordered_shipments).to eq([
        { description: 'Macbook air', count: 1 },
        { description: 'Iphone', count: 2 }
      ])
    end
  end
end

