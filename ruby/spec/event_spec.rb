# frozen_string_literal: true

require_relative '../lib/events/author_created_event.rb'
require_relative '../lib/event_store.rb'

RSpec.describe 'the event' do
  context 'raising an event' do
    it 'checks the parameters' do
      expect { AuthorCreatedEvent.dispatch(invalid: 'parameter') }.to raise_error RuntimeError
    end
  end
end
