require_relative '../../test_helper'
require 'sip/ubicacion_helper'

module Sip
  class UbicacionHelperTest < ActionView::TestCase

    include UbicacionHelper

    def contexto_p
      @pais = Pais.find(862) 
      @ubicacion = Ubicacion.create({
        pais: @pais
      })
    end

    test "simple" do
      contexto_p
      assert @ubicacion.valid?
    end

    test "nombre con sólo país" do
      contexto_p
      assert_equal formato_ubicacion(@ubicacion), "Venezuela"
    end

    def contexto_d
      contexto_p
      @departamento = Departamento.where(id: 1).take
      @ubicacion.id_departamento = @departamento.id
    end

    test "nombre con pais y departamento" do
      contexto_d
      assert_equal formato_ubicacion(@ubicacion), 
        "Venezuela / Distrito Capital"
    end

    def contexto_m
      contexto_d
      @municipio = Municipio.where(id:25).take
      @ubicacion.id_municipio = @municipio.id
    end

    test "nombre con municipio" do
      contexto_m
      assert_equal formato_ubicacion(@ubicacion),
        "Venezuela / Distrito Capital / Bolivariano Libertador"
    end

    def contexto_c
      contexto_m
      @clase = Clase.where(id_municipio: 25).take
      @ubicacion.id_clase = @clase.id
    end

    test "no incluye clase" do
      contexto_c
      assert_equal formato_ubicacion(@ubicacion, false),
        "Venezuela / Distrito Capital / Bolivariano Libertador"
    end

    test "incluye clase" do
      contexto_c
      assert_equal formato_ubicacion(@ubicacion),
        "Venezuela / Distrito Capital / Bolivariano Libertador / Caracas"
    end

  end  # class
end    # module
