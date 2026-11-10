defmodule Util do
  def mostrar_mensaje_java(mensaje) do
    System.cmd("java", ["-cp", ".", "Mensaje", mensaje])
  end

  def mostrar_mensaje(mensaje) do
    mensaje
    |> IO.puts()
  end

  #pattern matching
  def ingresar(mensaje, :texto) do #atomo :texto
    mensaje
    |> IO.gets()
    |> String.trim()
  end

  def ingresar(mensaje, :entero) do #atomo :entero
    mensaje
    |> IO.gets()
    |> String.trim()
    |> String.to_integer()
  end

  def ingresar(mensaje, :real) do
    mensaje
    |> IO.gets()
    |> String.trim()
    |> String.to_float()
  end

  def ingresar(mensaje, :booleano) do
    respuesta =
      mensaje
      |> IO.gets()
      |> String.trim()
      |> String.downcase()

    respuesta in ["s", "si", "sí"]
  end

  def ingresar(mensaje, :lista) do
    mensaje
    |> IO.gets()
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  #ingresar entero con manejo de excepciones con case y recursion
  def ingresar_excepcion(mensaje, :entero) do #atomo :entero
    entrada = mensaje |> IO.gets() |> String.trim()

    case Integer.parse(entrada) do
      {num, _} -> num
      :error ->
        IO.puts("Error: Debe ingresar un número entero válido.")
        ingresar_excepcion(mensaje, :entero)
    end
  end

  #ingresar real con manejo de excepciones con Try do y rescue
  def ingresar_excepcion(mensaje, :real) do
    try do
      mensaje
      |> IO.gets()
      |> String.trim()
      |> String.to_float()
    rescue
      ArgumentError ->
        IO.puts("Error: Se espera que ingrese un número real válido.")
        ingresar_excepcion(mensaje, :real)
    end
  end

  def ingresar_excepcion(mensaje, :lista) do
    case ingresar(mensaje, :lista) do
      [] ->
        IO.puts("Error: Debe ingresar al menos un síntoma.")
        ingresar_excepcion(mensaje, :lista)

      lista ->
        lista
    end
  end
end
