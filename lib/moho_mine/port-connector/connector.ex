defmodule MohoMine.PortConnector.Connector do
  @moduledoc """
  Connects to external applications via Ports
  """
  require Logger
  @script_folder "lib/moho_mine/reporter/scripts/"
  @jdbc_driver "lib/moho_mine/reporter/odbc/jaybird-full-2.2.11.jar"

  defmodule RSettings do
    defstruct script_name: nil, output_files: nil, parameters: []
  end

  @doc """
  Runs an R script file with arbitrary parameters
  """
  def run_r_script(settings) do
    #--vanilla omits any context/saved/etc settings
    params_in_string = convert_parameters_to_string(settings.parameters)
    script_with_path = get_script_with_path(settings.script_name)
    command = "Rscript --vanilla #{script_with_path} #{@jdbc_driver} #{settings.output_files |> Enum.join(" ")} #{params_in_string}"
    port = Port.open({:spawn, command}, [:binary])

    receive do
      {^port, {:data, result}} ->
        result
      after 300000 ->
        Logger.warn "A command timed out: \"#{command}\""
        :timeout
    end
  end

  defp convert_parameters_to_string(parameters) do
    case length(parameters) do
      0 ->
        ""
      _ ->
        parameters
        |> Enum.reduce("", fn(x, acc) -> acc <> " #{x}" end)
        |> String.strip
    end
  end

  defp get_script_with_path(script_name) do
    "#{@script_folder}#{script_name}"
  end
end
