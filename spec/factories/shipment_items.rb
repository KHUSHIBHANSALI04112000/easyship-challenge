
FactoryBot.define do
  factory :shipment_item do
    description { Faker::Lorem.word } 
    association :shipment
  end
end
