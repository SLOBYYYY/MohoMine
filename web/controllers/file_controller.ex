defmodule MohoMine.FileController do
  use MohoMine.Web, :controller

  def download(conn, %{"file_name" => file_name}) do
    do_download(conn, file_name, :uploaded)
  end

  def download_report(conn, %{"file_name" => file_name}) do
    do_download(conn, file_name, :report)
  end

  defp do_download(conn, file_name, type) do
    file_with_path = generate_absolut_path_to_report_file(file_name, type)
    IO.inspect file_with_path
    case File.open file_with_path do
      {:ok, file_handle} ->
        conn
        |> put_resp_content_type("application/csv")
        |> put_resp_header("Content-disposition", "attachment; filename=\"#{file_name}\"")
        |> send_file(200, file_with_path)
      {:error, _} ->
        conn
        |> send_resp(404, "File not found")
    end
  end

  defp generate_absolut_path_to_report_file(file_name, type) do
    file_settings_env = Application.get_env(:moho_mine, :file_settings)
    case type do
      :report ->
        "#{file_settings_env[:report]}#{file_name}"
      _ ->
        "#{file_settings_env[:uploaded]}#{file_name}"
    end
  end
end
