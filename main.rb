#!/usr/bin/env ruby

# require 'bundler/inline'

# gemfile do
#   source 'https://rubygems.org'
#   gem 'mysql2'
# end

require 'csv'
require 'pry'

TYPE = 'Transaction Type'
IGNORED_TYPES = Set['deposit', 'withdrawal']

file_name = ARGV[0] || raise('Please provide a file name')

class Transaction

  attr_reader :type, :asset, :amount, :price, :total

  def initialize(type, asset, amount, price)
    @type = type
    @asset = asset
    @amount = amount.to_f
    @price = price.to_f
    @total = @amount * @price
  end

  def self.buy(row)
    new(:buy, row['Asset'], row['Amount Asset'], row['Asset market price'])
  end

  def self.sell(row)
    new(:sell, row['Asset'], row['Amount Asset'], row['Asset market price'])
  end

  def self.zero()
    new(:sell, 'none', 0, 0)
end

movements_by_asset = Hash.new { |h, k| h[k] = [] }

def calculate_remaining_transactions(sold, transanctions)
  new_transactions = []
  gain = 0

  transanctions.each do |purchase|
    if sold.total <= 0
      new_transactions << purchase
    elsif purchase.amount >= sold.amount
      new_amount = purchase.amount - sold.amount
      new_transactions << Transaction.buy(purchase.asset, new_amount, purchase.price)
      gain += sold.amount * (purchase.price - sold.price)
      sold = Transaction.zero()
    else
      gain += purchase.total
      sold = Transaction.sell(sold.asset, sold.amount - purchase.amount, sold.price)
    end
  end

  new_transactions
end

CSV.foreach(file_name, headers: true) do |row|
  type = row[TYPE]
  next if IGNORED_TYPES.include?(type)

  case type
  when 'buy'
    purchase = Transaction.buy(row)
    movements_by_asset[purchase.asset] << purchase
  when 'sell'

  when 'transfer'
  else
    println "Unknown type: #{type}"
  end
end
