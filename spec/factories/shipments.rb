FactoryBot.define do
  factory :shipment do
    association :company, factory: :company

    after(:create) do |shipment|
      create_list(:shipment_item, 2, description: "Iphone",shipment: shipment)
      create_list(:shipment_item, 1, description: "Macbook air",shipment: shipment)
    end
  end
end
