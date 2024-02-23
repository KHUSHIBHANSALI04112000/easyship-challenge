FactoryBot.define do
  factory :company do

    trait :with_shipments do
      transient do
        shipments_count { 2 }
      end

      after(:create) do |company, evaluator|
        create_list(:shipment, evaluator.shipments_count, company: company)
      end
    end
  end
end
