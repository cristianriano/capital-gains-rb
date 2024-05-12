# frozen_string_literal: true

require_relative '../main'

describe :main do
  context 'when buying and selling' do
    it 'returns empty transactions when all was sold' do
      remaining, gains = run('spec/fixtures/sell_all.csv')

      expect(remaining.values.flatten).to be_empty
      expect(gains.count).to be(1)
      expect(gains[2021]).to be(27.5)
    end
  end
end