# frozen_string_literal: true
# encoding: utf-8

require_relative '../../lib/collections/books.rb'

RSpec.describe 'the patrons collection' do
  it 'the update method updates the disposition in the patrons collection' do
    patrons = Patrons.create
    john = Patron.new(name: 'John Smith')

    patrons.add(john).update(john) { |_| PatronDisposition.poor }
    expect(patrons[john]).to eq PatronDisposition.poor
  end

  it "updating a patron's standing directly does not update the patrons collection" do
    # pending 'this should work the same as Books but does not, find out why'

    patrons = Patrons.create
    john = Patron.new(name: 'John Smith')
    patrons.add(john)

    patrons.update(john) { |_| PatronDisposition.poor }
    expect(patrons[john].standing).to eq :poor

    patrons[john].change_standing :good
    expect(patrons[john].standing).to eq :poor
  end
end
