module Sip
  module Admin
    class FuentesprensaController < Sip::Admin::BasicasController
      before_action :set_fuenteprensa, 
        only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource  class: Sip::Fuenteprensa

      def clase 
        "Sip::Fuenteprensa"
      end

      def set_fuenteprensa
        @basica = Fuenteprensa.find(params[:id])
      end

      def fuenteprensa_params
        params.require(:fuenteprensa).permit(*atributos_form)
      end

    end
  end
end
