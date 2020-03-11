class Imap 
    include ActiveModel::Model 

    attr_accessor :source_name, :source_host, :source_port, :source_ssl,:source_pass,
    :dest_name, :dest_host, :dest_port, :dest_ssl,:dest_pass,:dest_user, :source_user

   
  
    validates_presence_of :source_name, :source_host, :source_port, :source_ssl,:source_pass,
    :dest_name, :dest_host, :dest_port, :dest_ssl,:dest_pass,:dest_user, :source_user

    validates_format_of :source_name,:dest_name, :with => /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/ 
    # validates_format_of :source_host, :with => /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/ 
    # validates_format_of :dest_name, :with => /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/ 
    # validates_format_of :dest_host, :with => /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/ 

end
