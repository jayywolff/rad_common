FactoryBot.define do
  factory :phone_number, class: 'String' do
    skip_create

    transient do
      phone_number do
        if RadicalTwilio.new.twilio_enabled?
          RadicalConfig.test_phone_number!
        else
          Faker::PhoneNumber.phone_number
        end
      end
    end

    trait :mobile do
      phone_number do
        if RadicalTwilio.new.twilio_enabled? || RadicalConfig.authy_enabled?
          RadicalConfig.test_mobile_phone!
        else
          Faker::PhoneNumber.cell_phone
        end
      end
    end

    trait :fax do
      phone_number do
        if RadicalTwilio.new.twilio_enabled?
          RadicalConfig.test_fax_number!
        else
          Faker::PhoneNumber.phone_number
        end
      end
    end

    initialize_with { new(phone_number) }
  end
end
