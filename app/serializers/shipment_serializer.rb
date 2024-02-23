class ShipmentSerializer < ActiveModel::Serializer
  attributes :id, :company_id, :destination_country, :origin_country, :tracking_number, :slug, :created_at, :shipment_items

  def shipment_items
    object.shipment_items.group(:description).count.map { |description, count| { description: description, count: count } }
  end
end
