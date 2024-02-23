class ShipmentSerializer < ActiveModel::Serializer
    attributes :company_id, :destination_country, :origin_country, :tracking_number, :slug, :created_at, :shipment_items
  
    def initialize(object, options = {})
      super(object, options)
      @sort_order = options[:items_order] || nil
    end
 
    def shipment_items
      object.shipments_ordered_by_items_count(@sort_order)
    end
end
