# frozen_string_literal: true
# encoding: utf-8

require_relative '../lib/patron_book_disposition.rb'

RSpec.describe 'the patron book disposition' do
  context 'adding books' do
    it 'the "none" object shows no copies borrowed' do
      expect(PatronBookDisposition.none.borrowed).to eq 0
    end

    it 'adding to borrowed returns a new object with more books borrowed' do
      subject = PatronBookDisposition.none.add_borrowed 3
      expect(subject).not_to be PatronBookDisposition.none
      expect(subject).not_to eq PatronBookDisposition.none
      expect(subject.borrowed).to eq 3
    end
  end

  context 'subtracting books' do
    it 'subtracting from borrowed returns a new object with less books borrowed' do
      subject = PatronBookDisposition.none.add_borrowed(3).subtract_borrowed 2
      expect(subject.borrowed).to eq 1
    end

    it 'trying to subtract more books from borrowed than stock returns zero books borrowed' do
      subject = PatronBookDisposition.none.add_borrowed(3).subtract_borrowed 4
      expect(subject.borrowed).to eq 0
    end
  end
end
