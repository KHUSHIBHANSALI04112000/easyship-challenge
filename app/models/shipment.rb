class Shipment < ApplicationRecord
  belongs_to :company
  has_many :shipment_items
 
  def group_shipment_items_by_description_and_sort_order(sort_order = "asc")
    item_counts_by_description = shipment_items.group(:description).count

    sorted_description_counts = item_counts_by_description.sort_by { |description, count| count }
    sorted_description_counts.reverse! if sort_order != 'asc'

    sorted_description_counts.map { |description, count| { description: description, count: count } }
  end
end