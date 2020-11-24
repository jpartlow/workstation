require 'spec_helper'

describe 'workstation::pe_acceptance' do
  let(:params) do
    {
      user: 'test',
    }
  end

  include_context('fake files',
    {
      '/home/test/.fog'                   => 'foggy',
      '/home/test/.ssh/id_rsa-acceptance' => 'key',
    }
  )

  it { is_expected.to compile.with_all_deps }
end
