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
    base_filenames = ["sales_by_category.csv", "sales_by_site.csv", "full_report.csv"]
    filenames_with_timestamps = base_filenames
      |> Enum.map(&generate_file_name_with_timestamp(&1))
    settings = %Connector.RSettings{script_name: "AgentSales.R", parameters: [from, to], output_files: (filenames_with_timestamps |> Enum.map(&generate_absolut_path_to_report_file(&1)))}
    case Connector.run_r_script(settings) do
      :timeout ->
        {:timeout, nil}
      "OK" ->
        {:ok, filenames_with_timestamps}
      error->
        Logger.error error
        {:error, nil}
    end
  end

  defp generate_file_name_with_timestamp(file_name) do
    {{year, month, day}, {hour, minute, second}} = :calendar.universal_time
    {file_name_root, extension} = get_name_and_extension(file_name)
    formatted_extension = if(extension != "", do: ".#{extension}", else: extension)
    "#{file_name_root}_#{year}_#{String.rjust(month |> Integer.to_string,2,?0)}_#{String.rjust(day |> Integer.to_string,2,?0)}_#{String.rjust(hour |> Integer.to_string,2,?0)}_#{String.rjust(minute |> Integer.to_string,2,?0)}_#{String.rjust(second |> Integer.to_string,2,?0)}#{formatted_extension}"
  end

  defp get_name_and_extension(file_name) do
    case length(String.split(file_name, ".")) do
      1 ->
        {file_name, ""}
      _ ->
        file_name_without_extension = 
          String.split(file_name, ".") |> Enum.reverse |> Enum.drop(1) |> Enum.reverse |> Enum.join(".")
        file_extension = String.split(file_name, ".") |> Enum.reverse |> Enum.take(1)
        {file_name_without_extension, file_extension}
    end
  end

  defp generate_absolut_path_to_report_file(file_name) do
    file_settings_env = Application.get_env(:moho_mine, :file_settings)
    "#{file_settings_env[:report]}#{file_name}"
  end
end
