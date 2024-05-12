# frozen_string_literal: true

require_relative '../main'

describe :main do
  context 'when purchased only once' do
    it 'returns empty transactions when all was sold' do
      remaining, gains = run('spec/fixtures/sell_all.csv')

      expect(remaining.values.flatten).to be_empty
      expect(gains.count).to be(1)
      expect(gains[2021]).to be(27.5)
    end

    it 'returns remaining asset when some was sold' do
      remaining, gains = run('spec/fixtures/sell_some.csv')

      expect(remaining.keys.count).to be(1)

      res = remaining["S&P500"]
      expect(res.count).to be(1)
      expect(res.first.amount).to be(3.0)
      expect(res.first.price).to be(35.0)
      expect(res.first.total).to be(105.0)

      expect(gains.count).to be(1)
      expect(gains[2021]).to be(12.5)
    end

    it 'returns remaining asset when some was sold and loss' do
      remaining, gains = run('spec/fixtures/sell_some_loss.csv')

      expect(remaining.keys.count).to be(1)

      res = remaining["S&P500"]
      expect(res.count).to be(1)
      expect(res.first.amount).to be(2.5)
      expect(res.first.price).to be(35.0)
      expect(res.first.total).to be(87.5)

      expect(gains.count).to be(1)
      expect(gains[2021]).to be(-15.0)
    end
  end

  context 'when multiple purchases' do
    it 'returns empty transactions when all was sold' do
      remaining, gains = run('spec/fixtures/multiple_sells.csv')

      expect(remaining.values.flatten).to be_empty
      expect(gains.count).to be(1)
      expect(gains[2021]).to be(45.0)
    end

    it 'returns remaining transactions when some was sold and loss' do
      remaining, gains = run('spec/fixtures/multiple_sells_loss.csv')

      expect(remaining.keys.count).to be(1)

      res = remaining["S&P500"]
      expect(res.count).to be(1)
      expect(res.first.amount).to be(1.0)
      expect(res.first.price).to be(40.0)
      expect(res.first.total).to be(40.0)

      expect(gains.count).to be(1)
      expect(gains[2021]).to be(-50.0)
    end
  end
end
