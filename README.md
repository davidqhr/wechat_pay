# 功能

目前只有网页扫码支付

# 安装

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `wechat_pay` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:wechat_pay, "~> 0.1.0"}]
    end
    ```

  2. Ensure `wechat_pay` is started before your application:

    ```elixir
    def application do
      [applications: [:wechat_pay]]
    end
    ```

# 用法

```elixir

# in your config file

use Mix.Config

config :wechat_pay,
  appid:  "xxx",
  key:    "xxx",       # the length of the APIKEY should be 32
  mch_id: "xxx"


```

## unifiedorder

```elixir
WechatPay.unifiedorder(%{
  body: "test_product",
  out_trade_no: "test1",
  total_fee: 1,
  spbill_create_ip: "127.0.0.1",
  notify_url: "http://example.com/notify",
  trade_type: "NATIVE", # could be "JSAPI", "NATIVE" or "APP"
})

# success
%{
  appid: "wx________________",
  code_url: "weixin://wxpay/bizpayurl?pr=_______",
  mch_id: "__________",
  nonce_str: "L18C1VKyE12KhSEw",
  prepay_id: "wx20160924__________________________",
  result_code: "SUCCESS",
  return_code: "SUCCESS",
  return_msg: "OK",
  sign: "C6974CE2CC38FB84DA1465E3D78163B8",
  trade_type: "NATIVE"
}

# failed
%{
  return_code: "FAIL",
  return_msg: "XXXXXX"
}
```