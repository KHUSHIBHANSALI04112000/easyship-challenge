class ShipmentSerializer < ActiveModel::Serializer
  attributes :company_id, :destination_country, :origin_country,
             :tracking_number, :slug, :created_at, :items

  def items
    build_items_payload
  end

  private

  def build_items_payload
    items = object.shipment_items.group(:description).count.with_indifferent_access

    return [] unless items.any?

    items.map.each do |description, count|
      { description: description, count: count}
    end
  end
end