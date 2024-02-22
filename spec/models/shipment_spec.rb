require 'rails_helper'

RSpec.describe Shipment, type: :model do
  describe "group_shipment_items_by_description_and_sort_order" do 
    let(:company) { create(:company) }
    let(:shipment) { create(:shipment, company: company) }

    context 'fetch shipments ordered by count with respective description' do
      before do
        item_1 = create(:shipment_item, description: 'Iphone', shipment: shipment)
        item_2 = create(:shipment_item, description: 'Macbook air', shipment: shipment)
        item_3 = create(:shipment_item, description: 'Iphone', shipment: shipment)
      end

      it 'should return shipments ordered by item count in descending order if order specified is descending' do
        ordered_shipments = shipment.group_shipment_items_by_description_and_sort_order('desc')

        expect(ordered_shipments).to eq([
          { description: 'Iphone', count: 2 },
          { description: 'Macbook air', count: 1 },
        ])
      end

      it 'should return shipments ordered by item count in ascending order by default  if sort order is not specified' do
        ordered_shipments = shipment.group_shipment_items_by_description_and_sort_order

        expect(ordered_shipments).to eq([
          { description: 'Macbook air', count: 1 },
          { description: 'Iphone', count: 2 }
        ])
      end
    end
  end
end


