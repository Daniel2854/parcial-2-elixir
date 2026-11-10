defmodule Coordinador do
  @moduledoc """
  Se encarga únicamente de coordinar los procesos: lanza un trabajador por archivo,
  espera sus respuestas y entrega los datos ya validados.
  -version 1.0
  -autor: Daniel Gil
  -fecha: 2026-11-09
  """

  @doc """
  Lee ambos archivos de forma concurrente.
  Retorna {:ok, datos} o {:error, mensaje} indicando qué archivo falló.
  """
  def cargar_datos(ruta_ciudades, ruta_movimientos) do
    # Se lanzan los dos trabajadores ANTES de esperar cualquier respuesta
    spawn(Coordinador, :trabajador_ciudades, [self(), ruta_ciudades])
    spawn(Coordinador, :trabajador_movimientos, [self(), ruta_movimientos])

    %{}
    |> esperar_respuestas(2)
    |> procesar_respuestas()
  end

  @doc """
  Trabajador que lee y procesa el archivo de ciudades.
  """
  def trabajador_ciudades(coordinador, ruta) do
    send(coordinador, {:ciudades, Lector.leer(ruta, &Ciudad.convertir_linea/1)})
  end

  @doc """
  Trabajador que lee y procesa el archivo de movimientos.
  """
  def trabajador_movimientos(coordinador, ruta) do
    send(coordinador, {:movimientos, Lector.leer(ruta, &Movimiento.convertir_linea/1)})
  end

  # Caso base: ya llegaron las dos respuestas
  defp esperar_respuestas(respuestas, 0), do: respuestas

  # Caso recursivo: acepta las respuestas en cualquier orden
  defp esperar_respuestas(respuestas, pendientes) do
    receive do
      {:ciudades, resultado} ->
        esperar_respuestas(Map.put(respuestas, :ciudades, resultado), pendientes - 1)

      {:movimientos, resultado} ->
        esperar_respuestas(Map.put(respuestas, :movimientos, resultado), pendientes - 1)
    after
      5000 ->
        Map.merge(
          %{ciudades: {:error, :sin_respuesta}, movimientos: {:error, :sin_respuesta}},
          respuestas
        )
    end
  end

  # Los dos archivos se leyeron bien: se descartan los movimientos de ciudades inexistentes
  defp procesar_respuestas(%{ciudades: {:ok, ciudades}, movimientos: {:ok, movimientos}}) do
    validos =
      movimientos.registros
      |> Enum.filter(fn movimiento -> existe_ciudad?(ciudades.registros, movimiento.id_ciudad) end)

    rechazados_por_ciudad = length(movimientos.registros) - length(validos)

    {:ok,
     %{
       ciudades: ciudades.registros,
       movimientos: validos,
       rechazados_ciudades: ciudades.rechazados,
       rechazados_movimientos: movimientos.rechazados + rechazados_por_ciudad
     }}
  end

  # Alguno de los archivos falló: se indica cuál
  defp procesar_respuestas(respuestas) do
    mensaje =
      [
        mensaje_archivo("ciudades.txt", respuestas.ciudades),
        mensaje_archivo("movimientos.txt", respuestas.movimientos)
      ]
      |> Enum.reject(fn texto -> texto == "" end)
      |> Enum.join("\n")

    {:error, mensaje}
  end

  defp mensaje_archivo(nombre, {:error, motivo}), do: "Error al leer #{nombre}: #{motivo}"
  defp mensaje_archivo(_nombre, {:ok, _}), do: ""

  defp existe_ciudad?(ciudades, id_ciudad) do
    Enum.any?(ciudades, fn ciudad -> ciudad.id == id_ciudad end)
  end
end
