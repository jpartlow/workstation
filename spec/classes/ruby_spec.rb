require 'spec_helper'

describe 'workstation::ruby' do
  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_class('Rbenv') }
  it { is_expected.to contain_rbenv__build('2.4.3') }

  context 'with gems' do
    let(:params) do
      {
        :gems => [
          'foo',
          'bar',
        ] 
      }
    end

    it { is_expected.to contain_rbenv__gem('foo on 2.4.3') }
    it { is_expected.to contain_rbenv__gem('bar on 2.4.3') }
  end 
end
