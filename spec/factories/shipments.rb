FactoryBot.define do
  factory :shipment do
    association :company, factory: :company

    after(:create) do |shipment|
      create_list(:shipment_item, 3, description: "Iphone",shipment: shipment)
    end
  end
end
