defmodule MohoMine.FileController do
  use MohoMine.Web, :controller
  @file_upload_directory "/tmp/"

  def download(conn, %{"file_name" => file_name}) do
    file_path = @file_upload_directory <> file_name
    case File.open file_path do
      {:ok, file_handle} ->
        conn
        |> put_resp_content_type("application/csv")
        |> put_resp_header("Content-disposition", "attachment; filename=\"#{file_name}\"")
        |> send_file(200, file_path)
      {:error, _} ->
        conn
        |> send_resp(404, "File not found")
    end
  end
end
