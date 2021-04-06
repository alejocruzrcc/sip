# encoding: UTF-8

# http://stackoverflow.com/questions/1170148/run-rake-task-in-controller
require 'rake'
Rake::Task.clear # evitar cargar muchas veces en modo desarrollo
Rails.application.load_tasks 

require 'shellwords'

module Sip
  class Respaldo7zController < ApplicationController
    load_and_authorize_resource class: Sip::Respaldo7z

    def new 
      @respaldo7z = Respaldo7z.new()
      respond_to do |format|
          format.html { render :new, layout: 'application' }
      end
    end
   
    def create
      @respaldo7z = Respaldo7z.new(respaldo7z_params)
      respond_to do |format|
        if @respaldo7z.valid?
          Rake::Task['sip:vuelca'].reenable
          Rake::Task['sip:vuelca'].invoke
          archcopia = Sip::TareasrakeHelper::nombre_volcado(Sip.ruta_volcados)
          puts "archcopia=#{archcopia}"
          #desturl = File.join( Sip.dir_respaldo7z, "#{archcopia}.7z")
          #dest = File.join( Rails.root, 'public', desturl)
          # Quitamos el .sql final de archcopia
          dest = "#{archcopia[0..-5]}.7z"
          FileUtils.rm_f dest
          tamanexos=`du -s #{Sip.ruta_anexos}`.to_i
          if tamanexos > 100000000
            cmd = Shellwords.join(['7z', 'a', "-r", 
                                   "-p#{@respaldo7z.clave7z}", 
                                   dest, archcopia])
          else
            cmd = Shellwords.join(['7z', 'a', "-r", 
                                   "-p#{@respaldo7z.clave7z}", 
                                   dest, archcopia, Sip.ruta_anexos])
          end
          r = `#{cmd}`
          if $?.exitstatus == 0
            format.html { 
              send_file(dest,
                        type: "application/x-7z-compressed", 
                        disposition: "inline" )
            }
          else
            format.html { 
              flash.now[:error] = "Problemas generando con #{cmd}: #{r}" 
              render :new, layout: 'application'
            }
          end
          #format.html { redirect_to main_app.root_path, notice: "Respaldo creado, descarguelo de <a href='#{desturl}'>desturl</a>" }
        else
          format.html { render :new, layout: 'application' }
        end
      end
    end

    private

    def respaldo7z_params
      params.require(:respaldo7z).permit(:clave7z, :clave7z_confirmation)
    end

  end
end
