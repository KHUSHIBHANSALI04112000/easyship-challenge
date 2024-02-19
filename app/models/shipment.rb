class Shipment < ApplicationRecord
  belongs_to :company
  has_many :shipment_items

  def shipments_ordered_by_items_count(order)
    item_counts_by_description = shipment_items.group(:description).count

    sorted_description_counts = item_counts_by_description.sort_by { |description, count| count }
    sorted_description_counts.reverse! if order != 'asc'

    sorted_description_counts.map { |description, count| { description: description, count: count } }
  end
end