Code.require_file("util.ex")
Code.require_file("ciudad.exs")
Code.require_file("movimiento.exs")
Code.require_file("lector.exs")
Code.require_file("reporte.exs")
Code.require_file("coordinador.exs")

defmodule Sismos do
  @moduledoc """
  Programa principal del Observatorio Sismológico (reporte local).
  Pide los datos al coordinador, muestra el reporte y lo guarda en un archivo.
  -version 1.0
  -autor: Daniel Gil
  -fecha: 2026-11-09
  """

  @ruta_ciudades "resources/ciudades.txt"
  @ruta_movimientos "resources/movimientos.txt"
  @ruta_reporte "resources/reporte_sismos.txt"

  @doc """
  Función principal que inicia la ejecución del programa.
  """
  def main do
    case Coordinador.cargar_datos(@ruta_ciudades, @ruta_movimientos) do
      {:ok, datos} ->
        reporte = Reporte.generar_reporte_general(datos)

        reporte
        |> Util.mostrar_mensaje()

        reporte
        |> guardar_reporte()

      {:error, mensaje} ->
        mensaje
        |> Util.mostrar_mensaje()

        "Se conserva el reporte anterior."
        |> Util.mostrar_mensaje()
    end
  end

  defp guardar_reporte(reporte) do
    case File.write(@ruta_reporte, reporte) do
      :ok ->
        "\nReporte guardado en #{@ruta_reporte}"
        |> Util.mostrar_mensaje()

      {:error, motivo} ->
        "\nError al guardar el reporte: #{motivo}"
        |> Util.mostrar_mensaje()
    end
  end
end

Sismos.main()
