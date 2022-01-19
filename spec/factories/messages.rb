FactoryBot.define do
  factory :message, class: 'DispatchRider::Message' do
    subject { 'sample_handler' }
    body {{
      'key' => 'value',
      'guid' => DispatchRider::Debug::PUBLISHER_MESSAGE_GUID,
    }}
    initialize_with {  DispatchRider::Message.new(attributes) }
  end
end
