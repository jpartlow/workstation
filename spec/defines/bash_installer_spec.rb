require 'spec_helper'

describe 'workstation::bash_installer' do
  let(:title) { 'test' }
  let(:params) do
    {
      url: 'https://some.where/install.sh',
      creates: '/usr/bin/thing',
    }
  end

  it { is_expected.to compile.with_all_deps }
  
  it 'installs' do
    is_expected.to(
      contain_exec('install /usr/bin/thing')
        .with_command('curl -sSL https://some.where/install.sh | bash')
        .with_creates('/usr/bin/thing')
    )
  end

  it 'manages the file' do
    is_expected.to(
      contain_file('/usr/bin/thing')
        .with_owner('root')
        .with_group('root')
        .with_mode('0755')

    )
  end
end
