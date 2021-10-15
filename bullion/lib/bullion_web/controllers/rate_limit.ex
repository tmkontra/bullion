defmodule BullionWeb.RateLimit do
  import Phoenix.Controller
  import Plug.Conn
  require Logger

  @global_bucket_name "any_request"
  @bucket_duration 1_000 # 1 second
  @request_limit 5

  def init(_opts) do end

  def call(conn, _opts) do
    rate_limit(conn)
  end

  def rate_limit(conn, _options \\ []) do
    case check_rate(conn) do
      {:allow, _count} -> conn
      {:deny, _limit} -> render_error(conn)
      {:error, _reason} -> render_error(conn)
    end
  end

  defp check_rate(conn) do
    bucket_name(conn)
    |> Hammer.check_rate(@bucket_duration, @request_limit)
  end

  defp bucket_name(conn) do
    principal = case conn.remote_ip do
      nil -> "<unidentified>"
      addr -> addr |> Tuple.to_list |> Enum.join(".")
    end
    Logger.debug("Checking rate limit for principal: #{principal}")
    @global_bucket_name <> "_principal=" <> principal
  end

  defp render_error(conn) do
    conn
    |> send_resp(429, "")
  end
end
