describe('store', function()
  local Helper = require 'resty.web_shield.helper'
  local Store = require 'resty.web_shield.store'
  local store = Store.new()

  before_each(function()
    clear_redis()
  end)

  describe("incr_counter", function()
    it('should return current value', function()
      assert.is_equal(store:incr_counter('a', 3), 1)
      assert.is_equal(store:incr_counter('a', 3), 2)
      assert.is_equal(store:incr_counter('b', 3), 1)
    end)

    it('should expire value', function()
      local s = spy.on(Helper, 'time')
      s.callback = function() return 100 end
      assert.is_equal(store:incr_counter('a', 1), 1)
      local ttl = store.redis:ttl('a-100')
      assert.is_equal(ttl >= 1, true)
      assert.is_equal(ttl <= 2, true)
      ngx.sleep(1)
      assert.is_equal(store:incr_counter('a', 1), 1)
    end)
  end)
end)