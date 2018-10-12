require 'spec_helper'

describe 'workstation::ruby' do
  let(:params) do
    {
      :owner => 'biscuit',
    }
  end

  it { is_expected.to compile.with_all_deps }
  it do
    is_expected.to contain_class('Rbenv')
      .with_owner('biscuit')
      .with_group('biscuit')
      .with_install_dir('/home/biscuit/.rbenv')
      .with_manage_profile(false)
  end
  it { is_expected.to contain_rbenv__build('2.5.1') }

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
end
