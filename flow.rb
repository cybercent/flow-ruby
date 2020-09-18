require 'flow/access/access_services_pb'
require 'flow/execution/execution_services_pb'
require 'json'

class Flow
  def initialize(node_address)
    @stub = Access::AccessAPI::Stub.new(node_address, :this_channel_is_insecure)
  end

  def ping
    req = Access::PingRequest.new
    res = @stub.ping(req)
    res
  end

  def get_account(address)
    req = Access::GetAccountAtLatestBlockRequest.new(address: to_bytes(address))
    res = @stub.get_account_at_latest_block(req)
    res.account
  end

  def execute_script(script, args = [])
    req = Access::ExecuteScriptAtLatestBlockRequest.new(script: script, arguments: args)
    res = @stub.execute_script_at_latest_block(req)
    parse_json(res.value)
  end

  private

  def parse_json(event_payload)
    JSON.parse(event_payload, object_class: OpenStruct)
  end

  def to_bytes(string)
    [string].pack('H*')
  end

  def to_string(bytes)
    bytes.unpack('H*').first
  end
end
