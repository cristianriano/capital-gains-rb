#!/usr/bin/env ruby
# frozen_string_literal: true

# require 'bundler/inline'

# gemfile do
#   source 'https://rubygems.org'
#   gem 'mysql2'
# end

require 'csv'
require 'pry'
require 'date'

TYPE = 'Transaction Type'
IGNORED_TYPES = Set['deposit', 'withdrawal']
DATE_FORMAT = '%Y-%m-%d'

file_name = ARGV[0] || raise('Please provide a file name')

class Transaction
  attr_reader :type, :asset, :amount, :price, :total, :date

  def initialize(type, asset, amount, price, date)
    @type = type
    @asset = asset
    @amount = amount
    @price = price
    @date = date
    @total = @amount * @price
  end

  def self.buy(row)
    new(
      :buy,
      row['Asset'],
      row['Amount Asset'].to_f,
      row['Asset market price'].to_f,
      Date.strptime(row['Timestamp'], DATE_FORMAT)
    )
  end

  def self.sell(row)
    new(
      :sell,
      row['Asset'],
      row['Amount Asset'].to_f,
      row['Asset market price'].to_f,
      Date.strptime(row['Timestamp'], DATE_FORMAT)
    )
  end

  def copy(amount)
    Transaction.new(@type, @asset, amount, @price, @date)
  end
end

def calculate_gain(purchase, sold)
  sold.amount * (sold.price - purchase.price)
end

def calculate_remaining_transactions(sold, transanctions)
  new_transactions = []
  gain = 0

  transanctions.each do |purchase|
    if sold.amount <= 0
      new_transactions << purchase
      next
    elsif purchase.amount >= sold.amount
      new_amount = purchase.amount - sold.amount
      new_transactions << purchase.copy(new_amount) if new_amount > 0
      gain += calculate_gain(purchase, sold)
      sold = sold.copy(0)
    else
      gain += calculate_gain(purchase, sold)
      sold = sold.copy(sold.amount - purchase.amount)
    end
  end

  [new_transactions, gain]
end

def run(file)
  movements_by_asset = Hash.new { |h, k| h[k] = [] }
  gains_per_year = Hash.new { |h, k| h[k] = 0 }

  CSV.foreach(file, headers: true) do |row|
    type = row[TYPE]
    next if IGNORED_TYPES.include?(type)

    case type
    when 'buy'
      purchase = Transaction.buy(row)
      movements_by_asset[purchase.asset] << purchase
    when 'sell'
      sold = Transaction.sell(row)
      new_transactions, gain = calculate_remaining_transactions(sold, movements_by_asset[sold.asset])
      movements_by_asset[sold.asset] = new_transactions
      gains_per_year[sold.date.year] += gain
    when 'transfer'
    else
      println "Unknown type: #{type}"
    end
  end

  [movements_by_asset, gains_per_year]
end

# binding.pry
