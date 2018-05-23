require 'spec_helper'

describe 'workstation::dotfiles' do
  let(:params) do
    {
      :identity        => 'an_ssh_id_rsa',
      :user            => 'agituser',
    }
  end

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_vcsrepo('/home/agituser/.dotfiles') }
  it do
    is_expected.to contain_exec('initial checkout')
      .with_command(%r{/usr/bin/git --git-dir='/home/agituser/\.dotfiles' --work-tree='/home/agituser' checkout})
      .with_command(%r{/usr/bin/git --git-dir='/home/agituser/\.dotfiles' --work-tree='/home/agituser' config --local status\.showUntrackedFiles no})
      .with_onlyif(%r{/usr/bin/git --git-dir='/home/agituser/\.dotfiles' --work-tree='/home/agituser' status.* \| grep '\^D'})
      .with_require('Workstation::Repo[dotfiles]')
  end
end
