require 'spec_helper'

describe 'workstation::ssh' do
  let(:params) do
    {
      :user        => 'rspec',
      :public_keys => [
        [
          'foo-id_rsa.pub',
          'AAAAA...=',
        ],
      ]
    }
  end

  it { is_expected.to compile.with_all_deps }
end
