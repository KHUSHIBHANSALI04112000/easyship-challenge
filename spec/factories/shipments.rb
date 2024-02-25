FactoryBot.define do
  factory :shipment do
    tracking_number {SecureRandom.random_number(1000000)}
    association :company
  end
end
