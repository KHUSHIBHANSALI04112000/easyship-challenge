FactoryBot.define do
  factory :shipment do
    association :company, factory: :company
  end
end
