# encoding: UTF-8

module Sip
  module Concerns
    module Controllers
      module PersonasController

        extend ActiveSupport::Concern

        included do
          include ActionView::Helpers::AssetUrlHelper

          before_action :set_persona, only: [:show, :edit, :update, :destroy]
          load_and_authorize_resource class: Sip::Persona

          def clase
            "Sip::Persona"
          end

          def genclase
            return 'F'
          end

          def atributos_index
            atributos_show
          end

          def atributos_form
            a = atributos_show - [:id]
            return a
          end

          def atributos_show
            [ :id, 
              :nombres,
              :apellidos,
              :anionac,
              :mesnac,
              :dianac,
              :sexo,
              :pais,
              :departamento,
              :municipio,
              :clase,
              :nacionalde,
              :tdocumento,
              :numerodocumento
            ]
          end

          def index(c = nil)
            if c == nil
              c = Sip::Persona.all
            end
            if params[:term]
              term = Sip::Ubicacion.connection.quote_string(params[:term])
              consNomvic = term.downcase.strip #sin_tildes
              consNomvic.gsub!(/ +/, ":* & ")
              if consNomvic.length > 0
                consNomvic += ":*"
              end
              where = " to_tsvector('spanish', unaccent(persona.nombres) " +
                " || ' ' || unaccent(persona.apellidos) " +
                " || ' ' || COALESCE(persona.numerodocumento::TEXT, '')) @@ " +
                "to_tsquery('spanish', '#{consNomvic}')";

              partes = [
                'nombres',
                'apellidos',
                'COALESCE(numerodocumento::TEXT, \'\')'
              ]
              s = "";
              l = " persona.id ";
              seps = "";
              sepl = " || ';' || ";
              partes.each do |p|
                s += seps + p;
                l += sepl + "char_length(#{p})";
                seps = " || ' ' || ";
              end
              qstring = "SELECT TRIM(#{s}) AS value, #{l} AS id 
              FROM public.sip_persona AS persona
              WHERE #{where} ORDER BY 1";

              r = ActiveRecord::Base.connection.select_all qstring
              respond_to do |format|
                format.json { render :json, inline: r.to_json }
                format.html { render inline: 'No responde con parametro term' }
              end
            else
              super(c)
            end
          end

          # Remplaza persona por la elejida por el usuario en autocompletación
          def remplazar
          end


          def set_persona
            @persona = Sip::Persona.find(params[:id])
            @registro = @persona
          end

          def listaparams
            atributos_form + [
              :id_pais,
              :id_departamento,
              :id_municipio,
              :id_clase,
              :tdocumento_id,
              :id_destroy
            ]
          end

          def persona_params
            params.require(:persona).permit(listaparams)
          end

          
        end # include

      end
    end
  end
end
