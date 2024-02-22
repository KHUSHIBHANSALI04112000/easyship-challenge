json.shipment do
  json.company_id @shipment.company_id
  json.destination_country @shipment.destination_country
  json.origin_country @shipment.origin_country
  json.tracking_number @shipment.tracking_number
  json.slug @shipment.slug
  json.created_at @shipment.created_at
  json.items @shipment.shipments_ordered_by_items_count(params[:items_order] || 'desc') do |item|
    json.description item[:description]
    json.count item[:count]
  end
end