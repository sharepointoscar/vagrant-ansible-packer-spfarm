require_relative '../shared/spec_helper'

 # check WinRM
 describe port(5985) do
  it { should be_listening  }
end

# check RDP
describe port(3389) do
  it { should be_listening  }
end

describe user('SPOSCAR\vagrant') do
  it { should exist }
  it { should belong_to_group('Administrators')}
end

describe user('SPOSCAR\vagrant') do
  it { should exist }
  it { should belong_to_group('SPOSCAR\Domain Admins')}
end

describe command('Get-ExecutionPolicy') do
  its(:stdout) { should match /RemoteSigned/ }
  #its(:stderr) { should match /stderr/ }
  its(:exit_status) { should eq 0 }
end

# Should be a Domain Server
describe windows_feature('AD-Domain-Services') do
  it{ should be_installed.by("powershell") }
  
end

# ensure IIS is not running on the domain server
describe windows_feature('IIS-Webserver') do
  it{ should_not be_installed.by("dism") }
end

describe windows_feature('Web-Webserver') do
  it{ should_not be_installed.by("powershell") }
end
