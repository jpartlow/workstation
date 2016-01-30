require 'spec_helper'
describe 'workstation' do

  context 'with defaults for all parameters' do
    it { should contain_class('workstation') }
  end
end
