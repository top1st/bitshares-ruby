module Bitshares

  class Market

    include RPC

    attr_reader :base, :quote

    DATE_FORMAT = '%FT%R'.freeze

    # @TODO consider removing all usage of CHAIN/CLIENT 
    def initialize(base, quote)
      @base_hash, @quote_hash = CHAIN.get_assets(base, quote)
      @base, @quote = @base_hash['symbol'], @quote_hash['symbol']
      valid_market?(@base_hash['id'], @quote_hash['id'])
      @multiplier = multiplier
    end

    def ticker
      get_ticker(@base, @quote)
    end

    def lowest_ask
      ticker['lowest_ask']
    end

    def highest_bid
      ticker['highest_bid']
    end

    def mid_price
      return nil if highest_bid.nil? || lowest_ask.nil?
      (highest_bid + lowest_ask) / 2

    def order_book(limit=50)
      get_order_book(@base, @quote, limit)
    end

    def limit_orders(limit=50)
      get_limit_orders(@base, @quote, limit)
    end

    def trade_history(since=nil,to=nil,limit=100)
      since ||= Date.new(1970,1,1)
      to ||= Date.today
      get_trade_history(@base, @quote,
          since.strftime(DATE_FORMAT),
          to.strftime(DATE_FORMAT), limit)
    end

    def get_24_volume
      CLIENT.get_24_volume(@base, @quote)
    end

    # @TODO GRAPHENE PORT
    # THEESE METHODS NEED PORTING:
    # - blockchain_market_list_shorts
    # - last_fill
    # - blockchain_market_get_asset_collateral
    # - order.price

    private

    def valid_market?(quote_id, base_id)
      raise Err, 'Invalid market; quote ID <= base ID' if quote_id <= base_id
    end

    def multiplier
      @base_hash['precision'].to_f / @quote_hash['precision']
    end

  end
end
