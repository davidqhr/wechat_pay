defmodule WechatPay do
  @url "https://api.mch.weixin.qq.com"

  @doc """
  统一下单接口
  必须参数 [:body, :out_trade_no, :total_fee, :spbill_create_ip, :notify_url, :trade_type]
  """
  @unifiedorder_required_fields [:body, :out_trade_no, :total_fee, :spbill_create_ip, :notify_url, :trade_type]
  def unifiedorder(params) do
    params = merge_options(params)

    check_required(params, @unifiedorder_required_fields)

    send_request("#{@url}/pay/unifiedorder", params)
  end

  defp check_required(params, required_params) do
    Enum.each(required_params, fn(field) ->
      if Map.get(params, field) === nil do
        raise ArgumentError, message: "miss required keys #{field}"
      end
    end)
  end

  def merge_options(params) do
    config = get_configs()
    params = Map.merge(config, params)

    nonce_str = :crypto.strong_rand_bytes(12) |> :base64.encode
    Map.put(params, :nonce_str, nonce_str)
  end

  def get_configs do
    config = Enum.into(Application.get_all_env(:wechat_pay), %{})
    Map.delete(config, :included_applications)
  end

  defp send_request(url, params) do
    params = sign(params)
    xml = params_to_xml(params)

    res = HTTPotion.post url,
      body: xml,
      headers: [content_type: 'application/xml']

    body = res.body

    WechatPay.XMLParser.from_string(body)
  end

  def sign(params) do
    { key, params } = Map.pop(params, :key)

    key = case key do
      nil -> get_configs() |> Map.get(:key)
        _ -> key
    end

    query = params
      |> Enum.drop_while(&( to_string(elem(&1, 1)) === "" ))
      |> Enum.map(&("#{elem(&1, 0)}=#{elem(&1, 1)}"))
      |> Enum.join("&")

    query = "#{query}&key=#{key}"

    sign = :crypto.hash(:md5, query) |> Base.encode16(case: :upper)

    Map.put(params, :sign, sign)
  end

  def verify?(params) do
    {remote_sign, params} = Map.pop(params, :sign)
    sign = sign(params) |> Map.get(:sign)
    sign === remote_sign
  end

  def params_to_xml(params) do
    str = Enum.reduce(params, "", fn({k, v}, acc) ->
      acc <> "<#{k}>#{v}</#{k}>"
    end)

    "<xml>#{str}</xml>"
  end
end
