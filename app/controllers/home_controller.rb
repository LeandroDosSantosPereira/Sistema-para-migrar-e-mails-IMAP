class HomeController < ApplicationController
  def index
   
  end

  def imap
    @imap = Imap.new
  end

  def send_imap  
    @imap = Imap.new(imap_params)
    @contador = []   

    @hash_error_message = {}
    
    @senha1 = nil
    @senha2 = nil
    

      # Começa script ===========================================================
      
  require 'net/imap'


  @FOLDERS = {
    'INBOX' => 'INBOX',
    'sourcefolder' => 'gmailfolder'
  }

  # Maximum number of messages to select at once.
  @UID_BLOCK_SIZE = 100000

  # Utility methods.
  def dd(message)
    puts "[#{@imap.dest_name}] #{message}"
  end

  def ds(message)
    puts "[#{@imap.source_name}] #{message}"
  end

  def uid_fetch_block(server, uids, *args)
    pos = 0

    while pos < uids.size
      server.uid_fetch(uids[pos, @UID_BLOCK_SIZE], *args).each {|data| yield data }
      pos += @UID_BLOCK_SIZE
    end
  end

  @failures = 0
  @existing = 0
  @synced   = 0



  # ABRINDO CONEXÃO NO SERVIDOR DE ORIGEM========.
  ds 'Connecting...'
  begin
    source = Net::IMAP.new(@imap.source_host, @imap.source_port, @imap.source_ssl)
    rescue
      @imap.errors.add("Conexão_de_origem_:" ,"Parâmetros da conexão de origem incorretos")
    end
  
 

  ds 'Logging in...'
 
  begin
    source.login(@imap.source_name, @imap.source_pass)
    @senha1 = @imap.source_pass   
    rescue      
      @imap.errors.add("E-mail_de_origem_:" ,"Senha do e-mail de origem incorreto")

  end

 # ABRINDO CONEXÃO NO SERVIDOR DE DESTINO========.
  dd 'Connecting...'
  begin
    dest = Net::IMAP.new(@imap.dest_host, @imap.dest_port, @imap.dest_ssl)
    rescue
      @imap.errors.add("Conexão_de_destino_:" ,"Parâmetros da conexão de destino incorretos")
    end
  
 

  dd 'Logging in...'

  begin
    dest.login(@imap.dest_name, @imap.dest_pass)
    @senha2 = @imap.dest_pass
    rescue   
      @imap.errors.add("E-mail_de_destino_:" ,"Senha do e-mail de destino incorreto")
    end
    
    
    # Loop through folders and copy messages.
    @FOLDERS.each do |source_folder, dest_folder|
      # Open source folder in read-only mode.
      begin
        ds "Selecting folder '#{source_folder}'..."
        source.examine(source_folder)
      rescue => e
        ds "Error: select failed: #{e}"
        # @imap.errors.add("Erro_ao_selecionar_pasta_:" ,"Falha ao selecionar pasta no servidor de entrada")
        next
      end

      # Open (or create) destination folder in read-write mode.
      begin
        dd "Selecting folder '#{dest_folder}'..."
        dest.select(dest_folder)
      rescue => e
        begin
          dd "Folder not found; creating..."
          dest.create(dest_folder)
          dest.select(dest_folder)
          
        rescue => ee
          dd "Error: could not create folder: #{e}"
          # @imap.errors.add("Erro_ao_criar_pasta_:" ,"Falha ao criar pasta no servidor de destino")
          next
        end
      end
      
      # Build a lookup hash of all message ids present in the destination folder.
      dest_info = {}

      dd 'Analyzing existing messages...'
      uids = dest.uid_search(['ALL'])

      if uids.length > 0
        uid_fetch_block(dest, uids, ['ENVELOPE']) do |data|
          dest_info[data.attr['ENVELOPE'].message_id] = true
        end
      end

      dd "Found #{uids.length} messages"

      # Loop through all messages in the source folder.
      uids = source.uid_search(['ALL'])

      # ************************************Barra de progresso
      @tamanho = uids.length
          
      # ************************************


      ds "Found #{uids.length} messages"

      if uids.length > 0
        uid_fetch_block(source, uids, ['ENVELOPE']) do |data|
          mid = data.attr['ENVELOPE'].message_id

          # If this message is already in the destination folder, skip it.
          if dest_info[mid]
            @existing += 1
            next
          end

          # Download the full message body from the source folder.
          ds "Downloading message #{mid}..."
          msg = source.uid_fetch(data.attr['UID'], ['RFC822', 'FLAGS',
              'INTERNALDATE']).first

          # Append the message to the destination folder, preserving flags and
          # internal timestamp.
          dd "Storing message #{mid}..."

          tries = 0

          begin
            tries += 1
            dest.append(dest_folder, msg.attr['RFC822'], msg.attr['FLAGS'],
                msg.attr['INTERNALDATE'])

            @synced += 1
          rescue Net::IMAP::NoResponseError => ex
            if tries < 10
              dd "Error: #{ex.message}. Retrying..."
              sleep 1 * tries
              retry
            else
              @failures += 1
              dd "Error: #{ex.message}. Tried and failed #{tries} times; giving up on this message."
            
            end
          end
        end
      end      
      source.close
      dest.close    
    end

    puts "Finished. Message counts: #{@existing} untouched, #{@synced} transferred, #{@failures} failures."
      # Final de script ========================================================= 


     if @imap.errors.present?
      # redirect_to imap_path(hash_error_message: @hash_error_message) 
      flash[:sucess] = "Os e-mails foram migrados com sucesso"
     
     else
       redirect_to imap_path, flash: { notice: "Seus dados foram enviados com sucesso." } 
     end 
      
  end

  private 
  def imap_params 
      params.require(:imap).permit(:source_name, :source_host, :source_port, :source_ssl, :source_pass,
        :dest_name, :dest_host, :dest_port, :dest_ssl, :dest_pass,:dest_user, :source_user ) 
  end

end
