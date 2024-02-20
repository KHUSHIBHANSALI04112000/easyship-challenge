# app/helpers/shipment_helper.rb
module ShipmentHelper
    def transform_shipment_data(shipment)
      transformed_shipment = {
        "shipment": {
          "company_id": shipment.company_id,
          "destination_country": shipment.destination_country,
          "origin_country": shipment.origin_country,
          "tracking_number": shipment.tracking_number,
          "slug": shipment.slug,
          "created_at": shipment.created_at,
          "items": shipment.shipments_ordered_by_items_count(params[:items_order] || 'desc').map do |item|
            { "description": item[:description], "count": item[:count] }
          end
        }
      }
      transformed_shipment
    end
end
  