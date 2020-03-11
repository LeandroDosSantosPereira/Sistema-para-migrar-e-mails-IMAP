module ApplicationHelper
    def flash_message(messages=nil)
      errors = ""
      
      #raise
      messages.each do |key, value|
        errors += "<p class=\"#{key}\">#{value}</p>"
      end
  
      errors
     
    end
    
  end


# ====Tipos de Mensagens a passar na Controller====

# flash[:notice] = "Informações salvas com sucesso."
# flash[:warning] = "Preencha todos os campos obrigatórios."
# flash[:error] = "Não foi possível salvar as informações."
# flash[:info] = "Você tem mensagens não visualizadas."