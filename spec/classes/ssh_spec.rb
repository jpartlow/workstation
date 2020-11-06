require 'spec_helper'

describe 'workstation::ssh' do
  let(:params) do
    {
      :user        => 'rspec',
      :public_keys => [
        'foo-id_rsa.pub',
      ],
      :sshdir => '/tmp/ssh-test',
    }
  end

  include_context('fake files', { '/tmp/ssh-test/foo-id_rsa.pub' => 'ssh-rsa abcde foo' })

  it { is_expected.to compile.with_all_deps }
  it do
    is_expected.to contain_ssh_authorized_key('foo-id_rsa.pub')
      .with_key('abcde')
  end
end
