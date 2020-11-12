require 'spec_helper'

describe 'workstation::vim' do
  let(:params) do
    {
      :user     => 'someone',
      :bundles  => [
        {
          'clone_name' => 'vim-foo',
          'source'     => 'https://github.com/auser/foo.git',
        },
        {
          'clone_name' => 'vim-bar',
          'source'     => 'https://github.com/buser/bar.git',
        },
      ],
    }
  end

  context 'pathogen setup' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_file('/home/someone/.vim') }
    it { is_expected.to contain_file('/home/someone/.vim/autoload') }
    it { is_expected.to contain_file('/home/someone/.vim/bundle') }

    it do
      is_expected.to contain_vcsrepo('/home/someone/vim-pathogen')
    end
    it do
      is_expected.to contain_file('/home/someone/.vim/autoload/pathogen.vim')
        .with_ensure('link')
        .with_target('/home/someone/vim-pathogen/autoload/pathogen.vim')
        .that_requires('Vcsrepo[/home/someone/vim-pathogen]')
    end
  end

  context 'pathogen bundles' do
    it { is_expected.to contain_vcsrepo('/home/someone/.vim/bundle/vim-foo') }
    it { is_expected.to contain_vcsrepo('/home/someone/.vim/bundle/vim-bar') }
  end
end
