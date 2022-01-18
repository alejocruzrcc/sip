
module Sip
  module Concerns
    module Models
      module PersonaTrelacion
        extend ActiveSupport::Concern

        included do
          self.table_name = 'sip_persona_trelacion'
          belongs_to :personauno, foreign_key: "persona1", validate: true, 
            class_name: 'Sip::Persona', optional: false
          belongs_to :personados, foreign_key: "persona2", validate: true, 
            class_name: 'Sip::Persona', optional: false
          belongs_to :trelacion, foreign_key: "id_trelacion", validate: true, 
            class_name: 'Sip::Trelacion', optional: false

          accepts_nested_attributes_for :personados, reject_if: :all_blank
          accepts_nested_attributes_for :trelacion, reject_if: :all_blank

          validates :personauno, presence: true
          validates :personados, presence: true
          validates :trelacion, presence: true

          validates_uniqueness_of :persona1, scope: [:persona2, :id_trelacion]
        end
      end
    end
  end
end

