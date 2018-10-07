require 'serverspec'
require 'winrm'

set :backend, :winrm

opts = {
    user: ENV['domain_user'],
    password: ENV['domain_user_password'],
    endpoint: "http://#{ENV['TARGET_HOST']}:5985/wsman",
    operation_timeout: 300,
    transport: :negotiate
  }
 
  winrm = WinRM::Connection.new (opts)
  winrm.logger.level = :info
  Specinfra.configuration.winrm = winrm
