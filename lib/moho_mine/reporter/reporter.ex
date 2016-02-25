defmodule MohoMine.Reporter do
  @moduledoc """
  Reporter stores each custom report that creates a CSV file
  that will be available to download for the requiesting client
  """
  alias MohoMine.PortConnector.Connector
  require Logger

  @doc """
  A custom R based report that aggregates the sales of each agent
  based on the given date range
  """
  def aggregated_agent_sales(from, to) do
    settings = %Connector.RSettings{script_name: "AgentSales.R", parameters: [from, to], output_file: "/tmp/stuff.csv"}
    case Connector.run_r_script(settings) do
      :timeout ->
        {:timeout, nil}
      "OK" ->
        #todo: zip'em maybe?
        #provide download link
        {:ok, settings.output_file}
      error->
        Logger.error error
        {:error, nil}
    end
  end
end
