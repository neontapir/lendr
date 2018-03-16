# frozen_string_literal: true
# encoding: utf-8

require_relative '../../lib/dispositions/library_book_disposition.rb'

RSpec.describe 'the library book disposition' do
  context 'adding books' do
    it 'the "none" object shows no copies owned or in circulation' do
      expect(LibraryBookDisposition.none.owned).to eq 0
      expect(LibraryBookDisposition.none.in_circulation).to eq 0
    end

    it 'adding to owned returns a new object with more books owned' do
      subject = LibraryBookDisposition.none.add_owned 3
      expect(subject).not_to be LibraryBookDisposition.none
      expect(subject).not_to eq LibraryBookDisposition.none
      expect(subject.owned).to eq 3
      expect(subject.in_circulation).to eq 0
    end

    it 'adding to in circulation returns a new object with more books in circulation' do
      subject = LibraryBookDisposition.none.add_in_circulation 5
      expect(subject).not_to be LibraryBookDisposition.none
      expect(subject.owned).to eq 0
      expect(subject.in_circulation).to eq 5
    end
  end

  context 'subtracting books' do
    it 'subtracting from owned returns a new object with less books owned' do
      subject = LibraryBookDisposition.none.add_owned(3).subtract_owned 2
      expect(subject.owned).to eq 1
      expect(subject.in_circulation).to eq 0
    end

    it 'trying to subtract more books from owned than stock returns zero books owned' do
      subject = LibraryBookDisposition.none.add_owned(3).subtract_owned 4
      expect(subject.owned).to eq 0
      expect(subject.in_circulation).to eq 0
    end

    it 'subtracting from in circulation returns a new object with less books in circulation' do
      subject = LibraryBookDisposition.none.add_in_circulation(5).subtract_in_circulation 4
      expect(subject.owned).to eq 0
      expect(subject.in_circulation).to eq 1
    end

    it 'trying to subtract more books from in circulation than stock returns zero books in circulation' do
      subject = LibraryBookDisposition.none.add_in_circulation(5).subtract_in_circulation 6
      expect(subject.owned).to eq 0
      expect(subject.in_circulation).to eq 0
    end
  end
end
