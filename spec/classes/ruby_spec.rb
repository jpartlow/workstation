require 'spec_helper'

describe 'workstation::ruby' do
  let(:os_major) { '16.04' }
  let(:facts) do
    {
      'os'        => {
        'release' => {
          'major' => os_major,
        },
      },
    }
  end
  let(:params) do
    {
      :owner => 'biscuit',
    }
  end

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_package('build-essential') }
  it { is_expected.to contain_package('libgdbm-dev') }
  it do
    is_expected.to contain_class('Rbenv')
      .with_owner('biscuit')
      .with_group('biscuit')
      .with_install_dir('/home/biscuit/.rbenv')
      .with_manage_profile(false)
  end
  it { is_expected.to contain_rbenv__build('2.5.1') }
  it do
    is_expected.to contain_exec('add rbenv to .bashrc')
      .with_command(%r{echo .*rbenv init.* >> /home/biscuit/.bashrc}m)
      .with_user('biscuit')
      .with_unless(%r{grep .*rbenv init})
  end

  context 'with gems' do
    let(:params) do
      {
        :owner => 'biscuit',
        :gems => [
          'foo',
          'bar',
        ] 
      }
    end

    it { is_expected.to contain_rbenv__gem('foo on 2.5.1') }
    it { is_expected.to contain_rbenv__gem('bar on 2.5.1') }
  end

  context 'ubuntu 18.04' do
    let(:os_major) { '18.04' }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_package('build-essential') }
    it { is_expected.to_not contain_package('libgdbm3') }
  end
end
