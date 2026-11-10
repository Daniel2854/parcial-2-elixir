Code.require_file("util.ex")
Code.require_file("ciudad.exs")
Code.require_file("movimiento.exs")
Code.require_file("lector.exs")
Code.require_file("reporte.exs")
Code.require_file("coordinador.exs")

defmodule Servidor do
  @moduledoc """
  Nodo servidor del Observatorio Sismológico.
  Registra el proceso :servicio_sismos y atiende las consultas de los clientes.
  Reutiliza Coordinador y Reporte del punto 1.
  -version 1.0
  -autor: Daniel Gil
  -fecha: 2026-11-09
  """

  @ruta_ciudades "resources/ciudades.txt"
  @ruta_movimientos "resources/movimientos.txt"

  @doc """
  Función principal: registra el proceso del servicio y empieza a esperar solicitudes.
  """
  def main do
    Process.register(self(), :servicio_sismos)

    "Servidor listo en el nodo #{node()}. Esperando solicitudes..."
    |> Util.mostrar_mensaje()

    esperar_solicitudes()
  end

  # Espera una solicitud, la atiende y vuelve a esperar (llamada recursiva)
  defp esperar_solicitudes do
    receive do
      {destino_respuesta, solicitud} ->
        atender(destino_respuesta, solicitud)
    end

    esperar_solicitudes()
  end

  defp atender(destino_respuesta, {:reporte_ciudad, id_ciudad}) do
    "Solicitud recibida: reporte de la ciudad #{id_ciudad}"
    |> Util.mostrar_mensaje()

    case Coordinador.cargar_datos(@ruta_ciudades, @ruta_movimientos) do
      {:ok, datos} ->
        send(destino_respuesta, Reporte.generar_reporte_ciudad(datos, id_ciudad))

      {:error, mensaje} ->
        send(destino_respuesta, mensaje)
    end
  end

  defp atender(destino_respuesta, :reporte_general) do
    "Solicitud recibida: reporte general"
    |> Util.mostrar_mensaje()

    case Coordinador.cargar_datos(@ruta_ciudades, @ruta_movimientos) do
      {:ok, datos} ->
        send(destino_respuesta, Reporte.generar_reporte_general(datos))

      {:error, mensaje} ->
        send(destino_respuesta, mensaje)
    end
  end

  defp atender(destino_respuesta, :fin) do
    "Solicitud recibida: fin"
    |> Util.mostrar_mensaje()

    send(destino_respuesta, :fin)
  end

  # Cualquier otra solicitud se ignora para que el servidor no se caiga
  defp atender(_destino_respuesta, solicitud) do
    "Solicitud desconocida: #{inspect(solicitud)}"
    |> Util.mostrar_mensaje()
  end
end

Servidor.main()
