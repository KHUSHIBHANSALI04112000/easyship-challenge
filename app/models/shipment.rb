class Shipment < ApplicationRecord
  belongs_to :company
  belongs_to :shipment_item
end
