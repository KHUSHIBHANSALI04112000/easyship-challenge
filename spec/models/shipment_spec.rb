require 'rails_helper'

RSpec.describe Shipment, type: :model do
  describe "#group_shipment_items_by_description_and_sort_order" do 
    let(:company) { create(:company) }
    let(:shipment) { create(:shipment, company: company) }

    before do
      shipment.shipment_items[0].update(description: "Iphone")
      shipment.shipment_items[1].update(description: "Macbook air")
      shipment.shipment_items[2].update(description: "Iphone")  
    end

    context 'when sorting shipments by item count with respective description in descending order' do
      let(:sort_order) { 'desc' }

      it 'returns shipments ordered by item count in descending order if order specified is descending' do
        ordered_shipments = shipment.group_shipment_items_by_description_and_sort_order(sort_order)

        expect(ordered_shipments).to eq([
          { description: 'Iphone', count: 2 },
          { description: 'Macbook air', count: 1 },
        ])
      end
    end

    context 'when sorting shipments by item count with respective description in ascending order' do
      let(:sort_order) { 'asc' }

      it 'returns shipments ordered by item count in ascending order by default if sort order is ascending' do
        ordered_shipments = shipment.group_shipment_items_by_description_and_sort_order(sort_order)

        expect(ordered_shipments).to eq([
          { description: 'Macbook air', count: 1 },
          { description: 'Iphone', count: 2 }
        ])
      end
    end

    context 'when sorting shipments by item count with respective description in ascending order by default' do
      it 'returns shipments ordered by item count in ascending order by default if sort order is not specified' do
        ordered_shipments = shipment.group_shipment_items_by_description_and_sort_order

        expect(ordered_shipments).to eq([
          { description: 'Macbook air', count: 1 },
          { description: 'Iphone', count: 2 }
        ])
      end
    end
  end
end



